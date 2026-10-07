import base64
import html
import json
import logging
import os
import sys
from datetime import datetime, timezone

import requests
from tenacity import (
    before_sleep_log,
    retry,
    retry_if_exception_type,
    stop_after_attempt,
    wait_exponential,
)

from include.Python.TELTools import (
    getAzureSecret,
    getSnowFlakeConn,
    load_config,
    load_control_table,
    putSnowflakeDataFrame,
    read_runtime_config,
)


logger = logging.getLogger(__name__)
if not logger.handlers:
    handler = logging.StreamHandler()
    handler.setFormatter(logging.Formatter('%(asctime)s %(levelname)s - %(message)s', '%Y-%m-%d %H:%M:%S'))
    logger.addHandler(handler)
logger.setLevel(logging.INFO)

logging.getLogger('azure').setLevel(logging.WARNING)
logging.getLogger('snowflake.connector').setLevel(logging.WARNING)

requests.packages.urllib3.disable_warnings()

HTTP_TIMEOUT = 60
DEFAULT_WORK_ITEM_CONFIG_PATH = '/usr/local/airflow/include/Configuration/TelTools_AzureDevops_Monday.json'
LOCAL_WORK_ITEM_CONFIG_PATH = os.path.abspath(
    os.path.join(os.path.dirname(__file__), '..', 'Configuration', 'TelTools_AzureDevops_Monday.json')
)
WORK_ITEM_CONFIG_PATH = os.environ.get('TELTOOLS_AZURE_DEVOPS_CONFIG_PATH', DEFAULT_WORK_ITEM_CONFIG_PATH)
if not os.path.exists(WORK_ITEM_CONFIG_PATH):
    WORK_ITEM_CONFIG_PATH = LOCAL_WORK_ITEM_CONFIG_PATH
STAGING_TABLE_PREFIX = "MONDAY_UPDATES_"
POSTED_TABLE_SUFFIX = "_POSTED"
POST_CONTROL_PREFIX = "DEVOPS_HISTORY_"


def get_updates_stage_table_name(base_table_name):
    return f"{STAGING_TABLE_PREFIX}{base_table_name}".upper()


def get_posted_updates_table_name(base_table_name):
    return f"{get_updates_stage_table_name(base_table_name)}{POSTED_TABLE_SUFFIX}".upper()


def get_post_control_key(base_table_name):
    return f"{POST_CONTROL_PREFIX}{base_table_name}".upper()


def parse_timestamp(value):
    if value is None or value == "":
        return None

    if isinstance(value, datetime):
        if value.tzinfo is None:
            return value.replace(tzinfo=timezone.utc)
        return value.astimezone(timezone.utc)

    text = str(value).strip()
    if not text:
        return None

    normalized = text.replace('Z', '+00:00') if text.endswith('Z') else text
    try:
        parsed = datetime.fromisoformat(normalized)
        if parsed.tzinfo is None:
            parsed = parsed.replace(tzinfo=timezone.utc)
        return parsed.astimezone(timezone.utc)
    except ValueError:
        pass

    formats = (
        "%Y-%m-%dT%H%M%S",
        "%Y-%m-%d %H:%M:%S",
        "%Y-%m-%dT%H:%M:%S",
        "%Y-%m-%d %H:%M:%S.%f",
        "%Y-%m-%dT%H:%M:%S.%f",
    )
    for fmt in formats:
        try:
            return datetime.strptime(text, fmt).replace(tzinfo=timezone.utc)
        except ValueError:
            continue

    return None


def format_timestamp(value):
    parsed = parse_timestamp(value)
    if parsed is None:
        return None
    return parsed.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


_devops_retry = retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=2, max=15),
    retry=retry_if_exception_type(requests.exceptions.RequestException),
    before_sleep=before_sleep_log(logger, logging.WARNING),
    reraise=True,
)


def get_monday_enabled_projects(item_ids=None):
    cfg_result = load_config(WORK_ITEM_CONFIG_PATH)
    if not cfg_result['status']:
        raise Exception(cfg_result['message'])

    projects = cfg_result['data'].get("WorkItems", [])
    enabled = [project for project in projects if project.get("enabled", True)]

    if item_ids:
        item_ids = {item_id.upper() for item_id in item_ids}
        enabled = [project for project in enabled if project.get("id", "").upper() in item_ids]

    return [project for project in enabled if project.get("WorkItemDetails", {}).get("MondayConn")]


def ensure_variant_stage_table(conn, table_name):
    ddl = f"""
        CREATE TABLE IF NOT EXISTS {table_name} (
            _FILENAME VARCHAR,
            _FILEDATE TIMESTAMP_NTZ,
            _UPLOADDATE TIMESTAMP_NTZ,
            JSONFIELD VARIANT
        )
    """
    cursor = conn.cursor()
    try:
        cursor.execute(ddl)
    finally:
        cursor.close()


def read_variant_records(conn, table_name, since_dt=None):
    cursor = conn.cursor()
    try:
        event_ts_expr = (
            'COALESCE(JSONFIELD:"event_created_at"::string, '
            'JSONFIELD:"monday_reply_created_at"::string, '
            'JSONFIELD:"monday_update_created_at"::string)'
        )
        query = f"SELECT JSONFIELD FROM {table_name}"
        params = []
        if since_dt is not None:
            query += f" WHERE TRY_TO_TIMESTAMP_TZ({event_ts_expr}) > TRY_TO_TIMESTAMP_TZ(%s)"
            params.append(format_timestamp(since_dt))
        query += f" ORDER BY TRY_TO_TIMESTAMP_TZ({event_ts_expr}), JSONFIELD:\"source_key\"::string"
        cursor.execute(query, params)
        rows = cursor.fetchall()
    finally:
        cursor.close()

    records = []
    for row in rows:
        payload = row[0]
        if isinstance(payload, str):
            payload = json.loads(payload)
        records.append(payload)
    return records


def read_posted_source_keys(conn, table_name):
    cursor = conn.cursor()
    try:
        cursor.execute(f"SELECT DISTINCT JSONFIELD:\"source_key\"::string FROM {table_name}")
        rows = cursor.fetchall()
    finally:
        cursor.close()
    return {row[0] for row in rows if row and row[0]}


def get_record_type(record):
    return record.get("record_type") or ("reply" if record.get("monday_reply_id") else "update")


def get_record_event_timestamp(record):
    return (
        record.get("event_created_at")
        or record.get("monday_reply_created_at")
        or record.get("monday_update_created_at")
    )


def dedupe_records(records):
    deduped = {}
    for record in sorted(records, key=lambda item: (get_record_event_timestamp(item) or "", item.get("source_key") or "")):
        source_key = record.get("source_key")
        if source_key:
            deduped[source_key] = record
    return list(deduped.values())


def build_history_value(record):
    record_type = get_record_type(record)
    event_created_at = get_record_event_timestamp(record)

    if record_type == "reply":
        metadata_lines = [
            f"Board: {record.get('board_name') or record.get('board_id')}",
            f"Monday Item: {record.get('monday_item_name')} ({record.get('monday_item_id')})",
            f"Author: {record.get('monday_reply_creator_name') or record.get('monday_creator_name') or 'Unknown'}",
            f"Created At (UTC): {event_created_at}",
        ]
        metadata_html = "<br/>".join(html.escape(str(line)) for line in metadata_lines if line)
        parent_update_html = html.escape(record.get("monday_update_text") or "").replace("\n", "<br/>")
        reply_html = html.escape(record.get("monday_reply_text") or "").replace("\n", "<br/>")
        parent_section = f"<p><strong>Parent Update</strong><br/>{parent_update_html}</p>" if parent_update_html else ""
        return f"<div><p><strong>Monday.com Reply</strong></p><p>{metadata_html}</p>{parent_section}<p>{reply_html}</p></div>"

    metadata_lines = [
        f"Board: {record.get('board_name') or record.get('board_id')}",
        f"Monday Item: {record.get('monday_item_name')} ({record.get('monday_item_id')})",
        f"Author: {record.get('monday_creator_name') or 'Unknown'}",
        f"Created At (UTC): {event_created_at}",
    ]
    metadata_html = "<br/>".join(html.escape(str(line)) for line in metadata_lines if line)
    body_html = html.escape(record.get("monday_update_text") or "").replace("\n", "<br/>")
    return f"<div><p><strong>Monday.com Update</strong></p><p>{metadata_html}</p><p>{body_html}</p></div>"


@_devops_retry
def append_work_item_history(org_url, work_item_id, pat, history_value):
    headers = {
        "Authorization": "Basic " + base64.b64encode(bytes(':' + pat, 'utf-8')).decode('ascii'),
        "Content-Type": "application/json-patch+json",
        "Accept": "application/json",
    }
    payload = [
        {
            "op": "add",
            "path": "/fields/System.History",
            "value": history_value,
        }
    ]
    url = f"{org_url}/_apis/wit/workitems/{work_item_id}?api-version=7.1-preview.3"
    response = requests.patch(
        url,
        headers=headers,
        data=json.dumps(payload),
        verify=False,
        timeout=HTTP_TIMEOUT,
    )

    if response.status_code in (429, 500, 502, 503, 504):
        raise requests.exceptions.RequestException(
            f"DevOps history append transient failure HTTP {response.status_code}: {response.text[:300]}"
        )

    if response.status_code not in (200, 201):
        raise Exception(
            f"DevOps history append failed for work item {work_item_id}: HTTP {response.status_code}: {response.text[:500]}"
        )

    return response.json()


def record_successful_post(db, schema, posted_table, record):
    logged_record = dict(record)
    logged_record["devops_posted_at"] = format_timestamp(datetime.now(timezone.utc))
    file_date = datetime.now(timezone.utc)
    file_name = f"{posted_table}_{file_date.strftime('%Y%m%dT%H%M%S')}.json"
    messages = putSnowflakeDataFrame(db, schema, posted_table, [logged_record], file_name, file_date, 1)
    if "FAIL_SIGNAL" in messages:
        raise Exception(f"Failed to persist post log for {record.get('source_key')}: {messages}")


def process_project(project, db):
    project_id = project.get("id")
    work_item_details = project.get("WorkItemDetails", {})
    site_config = work_item_details.get("SiteConfig", {})
    sf_config = work_item_details.get("SnowflakeConn", {})

    schema = sf_config["SNOWFLAKE_SCHEMA_NAME"]
    base_table = sf_config["SNOWFLAKE_TABLE_NAME"]
    stage_table = get_updates_stage_table_name(base_table)
    posted_table = get_posted_updates_table_name(base_table)
    control_key = get_post_control_key(base_table)

    logger.info(f"--- Posting Monday updates back to DevOps for project {project_id} ---")
    logger.info(f"Source Table: {stage_table} | Posted Log: {posted_table}")

    runtime_result = read_runtime_config(db, schema)
    if not runtime_result["status"]:
        raise Exception(f"Unable to read control table for {schema}.{control_key}")

    last_posted_dt = None
    if runtime_result["data"]:
        last_posted_dt = parse_timestamp(runtime_result["data"].get(control_key))

    conn, messages = getSnowFlakeConn(db, schema, [])
    if conn == 'no connection':
        raise Exception(f"Snowflake connection failed for {schema}: {messages}")

    pat = getAzureSecret(site_config["pat"]).value
    org_url = site_config["org_url"]
    run_start = datetime.now(timezone.utc)

    try:
        ensure_variant_stage_table(conn, stage_table)
        ensure_variant_stage_table(conn, posted_table)

        staged_records = dedupe_records(read_variant_records(conn, stage_table, last_posted_dt))
        if not staged_records:
            return {
                "status": "SUCCESS",
                "project_id": project_id,
                "table": stage_table,
                "history_posted": 0,
                "pending": 0,
            }

        posted_source_keys = read_posted_source_keys(conn, posted_table)
        pending_records = [record for record in staged_records if record.get("source_key") not in posted_source_keys]

        if not pending_records:
            max_existing_dt = max(
                (parse_timestamp(get_record_event_timestamp(record)) for record in staged_records),
                default=last_posted_dt,
            )
            if max_existing_dt and (last_posted_dt is None or max_existing_dt > last_posted_dt):
                control_result = load_control_table(
                    run_start.strftime("%Y-%m-%dT%H%M%S"),
                    format_timestamp(last_posted_dt),
                    format_timestamp(max_existing_dt),
                    run_start.strftime("%Y-%m-%dT%H%M%S"),
                    datetime.now(timezone.utc).strftime("%Y-%m-%dT%H%M%S"),
                    control_key,
                    'NA',
                    len(staged_records),
                    schema,
                    db,
                )
                if not control_result["status"]:
                    raise Exception(f"Control table update failed for {control_key}: {control_result['message']}")
            return {
                "status": "SUCCESS",
                "project_id": project_id,
                "table": stage_table,
                "history_posted": 0,
                "pending": 0,
            }

        posted_count = 0
        failures = []
        max_posted_dt = last_posted_dt

        for record in pending_records:
            try:
                history_value = build_history_value(record)
                append_work_item_history(org_url, record.get("azure_work_item_id"), pat, history_value)
                record_successful_post(db, schema, posted_table, record)
                posted_count += 1

                created_at = parse_timestamp(get_record_event_timestamp(record))
                if created_at and (max_posted_dt is None or created_at > max_posted_dt):
                    max_posted_dt = created_at
            except Exception as exc:
                failures.append({
                    "source_key": record.get("source_key"),
                    "azure_work_item_id": record.get("azure_work_item_id"),
                    "error": str(exc),
                })
                logger.error(
                    f"Failed to post Monday update {record.get('source_key')} to work item {record.get('azure_work_item_id')}: {exc}"
                )

        if failures:
            return {
                "status": "FAILED",
                "project_id": project_id,
                "table": stage_table,
                "history_posted": posted_count,
                "pending": len(pending_records) - posted_count,
                "error": f"{len(failures)} update(s) failed during DevOps history sync",
                "failures": failures,
            }

        if max_posted_dt and (last_posted_dt is None or max_posted_dt > last_posted_dt):
            control_result = load_control_table(
                run_start.strftime("%Y-%m-%dT%H%M%S"),
                format_timestamp(last_posted_dt),
                format_timestamp(max_posted_dt),
                run_start.strftime("%Y-%m-%dT%H%M%S"),
                datetime.now(timezone.utc).strftime("%Y-%m-%dT%H%M%S"),
                control_key,
                'NA',
                posted_count,
                schema,
                db,
            )
            if not control_result["status"]:
                raise Exception(f"Control table update failed for {control_key}: {control_result['message']}")

        return {
            "status": "SUCCESS",
            "project_id": project_id,
            "table": stage_table,
            "history_posted": posted_count,
            "pending": 0,
        }
    finally:
        conn.close()


def main(item_ids=None):
    try:
        db = os.environ["SNOWFLAKE_LZ"]
        if item_ids:
            item_ids = [item_id.upper() for item_id in item_ids]

        monday_projects = get_monday_enabled_projects(item_ids=item_ids)
        if item_ids and not monday_projects:
            logger.info(f"No Monday-enabled projects selected for item IDs: {', '.join(item_ids)}")
            return {
                "status": "SUCCESS",
                "projects_total": 0,
                "projects_loaded": 0,
                "projects_failed": 0,
                "history_posted": 0,
                "results": [],
            }

        results = []
        total_posted = 0
        for project in monday_projects:
            try:
                result = process_project(project, db)
            except Exception as exc:
                logger.error(f"Failed to post Monday updates for {project.get('id')}: {exc}")
                result = {
                    "status": "FAILED",
                    "project_id": project.get("id"),
                    "table": get_updates_stage_table_name(
                        project.get("WorkItemDetails", {}).get("SnowflakeConn", {}).get("SNOWFLAKE_TABLE_NAME", "")
                    ),
                    "history_posted": 0,
                    "pending": 0,
                    "error": str(exc),
                }
            results.append(result)
            if result["status"] == "SUCCESS":
                total_posted += result.get("history_posted", 0)

        failures = [result for result in results if result["status"] != "SUCCESS"]
        return {
            "status": "FAILED" if failures else "SUCCESS",
            "projects_total": len(monday_projects),
            "projects_loaded": len(results) - len(failures),
            "projects_failed": len(failures),
            "history_posted": total_posted,
            "results": results,
        }
    except Exception as exc:
        logger.error(f"Critical error in Monday-to-DevOps history sync: {exc}")
        return {
            "status": "FAILED",
            "projects_total": 0,
            "projects_loaded": 0,
            "projects_failed": 0,
            "history_posted": 0,
            "results": [],
            "error": str(exc),
        }


if __name__ == "__main__":
    result = main(item_ids=sys.argv[1:] if len(sys.argv) > 1 else None)
    sys.exit(0 if result.get("status") == "SUCCESS" else 1)