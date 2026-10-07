import logging
import os
import re
import sys
import time
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
ITEMS_PAGE_LIMIT = 50
UPDATES_LIMIT = 100
MONDAY_API_URL = "https://api.monday.com/v2"
DEFAULT_WORK_ITEM_CONFIG_PATH = '/usr/local/airflow/include/Configuration/TelTools_AzureDevops_Monday.json'
LOCAL_WORK_ITEM_CONFIG_PATH = os.path.abspath(
    os.path.join(os.path.dirname(__file__), '..', 'Configuration', 'TelTools_AzureDevops_Monday.json')
)
WORK_ITEM_CONFIG_PATH = os.environ.get('TELTOOLS_AZURE_DEVOPS_CONFIG_PATH', DEFAULT_WORK_ITEM_CONFIG_PATH)
if not os.path.exists(WORK_ITEM_CONFIG_PATH):
    WORK_ITEM_CONFIG_PATH = LOCAL_WORK_ITEM_CONFIG_PATH
FULL_LOAD_START = "1900-01-01T00:00:00Z"
FAR_FUTURE_TIMESTAMP = "9999-12-31 23:59:59"
STAGING_TABLE_PREFIX = "MONDAY_UPDATES_"
WORK_ITEM_ID_COLUMN_TITLE = "Work Item Id"


def resolve_monday_api_key(api_key_secret_name, project_id):
    api_key_secret_name = str(api_key_secret_name or "").strip()
    if not api_key_secret_name:
        raise ValueError(f"{project_id}: MondayConn.api_key is required")

    return getAzureSecret(api_key_secret_name).value

FETCH_ITEMS_QUERY = """
query FetchBoardUpdates($boardId: [ID!], $limit: Int!, $workItemIdCol: [String!]) {
  complexity {
    before
    after
    reset_in_x_seconds
  }
  boards(ids: $boardId) {
    name
        items_page(limit: $limit) {
      cursor
      items {
        id
        name
        updated_at
        column_values(ids: $workItemIdCol) {
          id
          text
        }
        updates(limit: 100) {
          id
          body
          text_body
          created_at
          updated_at
          creator {
            id
            name
          }
                    replies {
                        id
                        body
                        text_body
                        created_at
                        updated_at
                        creator {
                            id
                            name
                        }
                    }
        }
      }
    }
  }
}
""".replace('\n', ' ').replace('  ', ' ')

FETCH_ITEMS_QUERY_PAGINATED = """
query FetchBoardUpdatesPaginated($boardId: [ID!], $limit: Int!, $cursor: String, $workItemIdCol: [String!]) {
  complexity {
    before
    after
    reset_in_x_seconds
  }
  boards(ids: $boardId) {
    name
    items_page(limit: $limit, cursor: $cursor) {
      cursor
      items {
        id
        name
        updated_at
        column_values(ids: $workItemIdCol) {
          id
          text
        }
        updates(limit: 100) {
          id
          body
          text_body
          created_at
          updated_at
          creator {
            id
            name
          }
                    replies {
                        id
                        body
                        text_body
                        created_at
                        updated_at
                        creator {
                            id
                            name
                        }
                    }
        }
      }
    }
  }
}
""".replace('\n', ' ').replace('  ', ' ')


def get_updates_stage_table_name(base_table_name):
    return f"{STAGING_TABLE_PREFIX}{base_table_name}".upper()


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


def strip_html(value):
    if not value:
        return ""
    return re.sub(r'<[^>]+>', '', str(value)).strip()


def _is_retryable_error(exception):
    return isinstance(exception, requests.exceptions.RequestException)


_api_retry = retry(
    stop=stop_after_attempt(5),
    wait=wait_exponential(multiplier=1, min=2, max=30),
    retry=retry_if_exception_type(requests.exceptions.RequestException),
    before_sleep=before_sleep_log(logger, logging.WARNING),
    reraise=True,
)


@_api_retry
def execute_graphql(query, variables, api_key):
    headers = {
        "Authorization": api_key,
        "Content-Type": "application/json",
    }
    response = requests.post(
        MONDAY_API_URL,
        json={"query": query, "variables": variables},
        headers=headers,
        timeout=HTTP_TIMEOUT,
    )

    if response.status_code == 429:
        wait_seconds = int(response.headers.get("Retry-After", 15))
        logger.warning(f"Monday API rate limit hit. Waiting {wait_seconds}s before retry")
        time.sleep(wait_seconds)
        raise requests.exceptions.RequestException("Monday API rate limit")

    if response.status_code >= 500:
        raise requests.exceptions.RequestException(f"Monday API transient HTTP {response.status_code}")

    if response.status_code != 200:
        raise Exception(f"Monday API returned HTTP {response.status_code}: {response.text[:300]}")

    payload = response.json()
    if payload.get("errors"):
        error_text = str(payload["errors"])
        if "complexity" in error_text.lower() or "rate" in error_text.lower():
            logger.warning("Monday API complexity/rate response received; retrying")
            raise requests.exceptions.RequestException(error_text)
        raise Exception(f"Monday GraphQL error: {error_text}")

    complexity = payload.get("data", {}).get("complexity", {})
    remaining = complexity.get("after")
    reset_in = complexity.get("reset_in_x_seconds")
    if remaining is not None and remaining < 50000:
        wait_seconds = reset_in if reset_in and reset_in > 0 else 15
        logger.info(f"Low Monday complexity budget ({remaining}). Waiting {wait_seconds}s")
        time.sleep(wait_seconds)

    return payload.get("data", {})


def get_board_columns(board_id, api_key):
    query = """
    query ($boardId: [ID!]!) {
      boards(ids: $boardId) {
        columns {
          id
          title
          type
        }
      }
    }
    """
    data = execute_graphql(query, {"boardId": [int(board_id)]}, api_key)
    boards = data.get("boards", [])
    return boards[0].get("columns", []) if boards else []


def get_work_item_id_column_id(board_id, api_key):
    for column in get_board_columns(board_id, api_key):
        if column.get("title") == WORK_ITEM_ID_COLUMN_TITLE:
            return column.get("id")
    return None


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


def extract_work_item_id(item, work_item_id_col_id):
    for column in item.get("column_values", []) or []:
        if column.get("id") == work_item_id_col_id and column.get("text"):
            return str(column["text"]).strip()
    return None


def build_base_record(project_id, board_id, board_name, item, azure_work_item_id):
    return {
        "project_id": project_id,
        "board_id": str(board_id),
        "board_name": board_name,
        "monday_item_id": str(item.get("id", "")),
        "monday_item_name": item.get("name"),
        "azure_work_item_id": azure_work_item_id,
    }


def build_update_records(project_id, board_id, board_name, item, work_item_id_col_id, since_dt):
    azure_work_item_id = extract_work_item_id(item, work_item_id_col_id)
    if not azure_work_item_id:
        logger.warning(f"Skipping Monday item {item.get('id')} on board {board_id}: missing Work Item Id")
        return []

    records = []
    base_record = build_base_record(project_id, board_id, board_name, item, azure_work_item_id)
    for update in item.get("updates", []) or []:
        created_at = parse_timestamp(update.get("created_at"))
        update_text = strip_html(update.get("text_body") or update.get("body"))
        update_source_key = f"{board_id}:{item.get('id')}:{update.get('id')}"
        update_creator = update.get("creator") or {}

        if created_at is not None and created_at > since_dt and update_text:
            record = {
                **base_record,
                "record_type": "update",
                "source_key": update_source_key,
                "event_created_at": format_timestamp(created_at),
                "event_updated_at": format_timestamp(update.get("updated_at")),
                "parent_source_key": None,
                "monday_update_id": str(update.get("id", "")),
                "monday_update_created_at": format_timestamp(created_at),
                "monday_update_updated_at": format_timestamp(update.get("updated_at")),
                "monday_update_text": update_text,
                "monday_reply_id": None,
                "monday_reply_created_at": None,
                "monday_reply_updated_at": None,
                "monday_reply_text": None,
                "monday_creator_id": str(update_creator.get("id", "")),
                "monday_creator_name": update_creator.get("name"),
                "monday_reply_creator_id": None,
                "monday_reply_creator_name": None,
            }
            records.append(record)

        for reply in update.get("replies", []) or []:
            reply_created_at = parse_timestamp(reply.get("created_at"))
            if reply_created_at is None or reply_created_at <= since_dt:
                continue

            reply_text = strip_html(reply.get("text_body") or reply.get("body"))
            if not reply_text:
                continue

            reply_creator = reply.get("creator") or {}
            reply_record = {
                **base_record,
                "record_type": "reply",
                "source_key": f"{update_source_key}:{reply.get('id')}",
                "event_created_at": format_timestamp(reply_created_at),
                "event_updated_at": format_timestamp(reply.get("updated_at")),
                "parent_source_key": update_source_key,
                "monday_update_id": str(update.get("id", "")),
                "monday_update_created_at": format_timestamp(created_at),
                "monday_update_updated_at": format_timestamp(update.get("updated_at")),
                "monday_update_text": update_text,
                "monday_reply_id": str(reply.get("id", "")),
                "monday_reply_created_at": format_timestamp(reply_created_at),
                "monday_reply_updated_at": format_timestamp(reply.get("updated_at")),
                "monday_reply_text": reply_text,
                "monday_creator_id": str(reply_creator.get("id", "")),
                "monday_creator_name": reply_creator.get("name"),
                "monday_reply_creator_id": str(reply_creator.get("id", "")),
                "monday_reply_creator_name": reply_creator.get("name"),
            }
            records.append(reply_record)

    return records


def get_record_event_timestamp(record):
    return record.get("event_created_at") or record.get("monday_update_created_at")


def process_project(project, db):
    project_id = project.get("id")
    work_item_details = project.get("WorkItemDetails", {})
    monday_conn = work_item_details.get("MondayConn", {})
    sf_config = work_item_details.get("SnowflakeConn", {})

    schema = sf_config["SNOWFLAKE_SCHEMA_NAME"]
    base_table = sf_config["SNOWFLAKE_TABLE_NAME"]
    board_id = str(monday_conn.get("BOARD_ID", "")).strip()
    if not board_id:
        raise ValueError(f"{project_id}: MondayConn.BOARD_ID is required")
    stage_table = get_updates_stage_table_name(base_table)
    api_key = resolve_monday_api_key(monday_conn.get("api_key"), project_id)

    logger.info(f"--- Fetching Monday updates for project {project_id} ---")
    logger.info(f"Board: {board_id} | Stage Table: {stage_table}")

    runtime_result = read_runtime_config(db, schema)
    if not runtime_result["status"]:
        raise Exception(f"Unable to read control table for {schema}.{stage_table}")

    last_fetch_dt = None
    if runtime_result["data"]:
        last_fetch_dt = parse_timestamp(runtime_result["data"].get(stage_table))
    if last_fetch_dt is None:
        last_fetch_dt = parse_timestamp(FULL_LOAD_START)

    conn, messages = getSnowFlakeConn(db, schema, [])
    if conn == 'no connection':
        raise Exception(f"Snowflake connection failed for {schema}: {messages}")

    extraction_start = datetime.now(timezone.utc)
    total_items = 0
    total_updates = 0
    max_seen_item_updated_at = last_fetch_dt
    max_seen_event_at = last_fetch_dt

    try:
        ensure_variant_stage_table(conn, stage_table)

        work_item_id_col_id = get_work_item_id_column_id(board_id, api_key)
        if not work_item_id_col_id:
            raise Exception(f"Board {board_id} does not contain a '{WORK_ITEM_ID_COLUMN_TITLE}' column")

        board_name = project_id
        cursor_value = None
        page_number = 0

        while True:
            page_number += 1
            if cursor_value is None:
                variables = {
                    "boardId": [int(board_id)],
                    "limit": ITEMS_PAGE_LIMIT,
                    "workItemIdCol": [work_item_id_col_id],
                }
                data = execute_graphql(FETCH_ITEMS_QUERY, variables, api_key)
            else:
                variables = {
                    "boardId": [int(board_id)],
                    "limit": ITEMS_PAGE_LIMIT,
                    "cursor": cursor_value,
                    "workItemIdCol": [work_item_id_col_id],
                }
                data = execute_graphql(FETCH_ITEMS_QUERY_PAGINATED, variables, api_key)

            boards = data.get("boards", [])
            if not boards:
                break

            board_name = boards[0].get("name") or board_name
            items_page = boards[0].get("items_page", {})
            items = items_page.get("items", [])
            if not items:
                break

            total_items += len(items)
            page_records = []
            for item in items:
                item_updated_at = parse_timestamp(item.get("updated_at"))
                if item_updated_at and item_updated_at > max_seen_item_updated_at:
                    max_seen_item_updated_at = item_updated_at
                page_records.extend(
                    build_update_records(project_id, board_id, board_name, item, work_item_id_col_id, last_fetch_dt)
                )

            if page_records:
                for record in page_records:
                    event_created_at = parse_timestamp(get_record_event_timestamp(record))
                    if event_created_at and event_created_at > max_seen_event_at:
                        max_seen_event_at = event_created_at

                file_name = f"{stage_table}_{extraction_start.strftime('%Y%m%dT%H%M%S')}_page_{page_number:03d}.json"
                load_messages = putSnowflakeDataFrame(
                    db,
                    schema,
                    stage_table,
                    page_records,
                    file_name,
                    extraction_start,
                    len(page_records),
                )
                if "FAIL_SIGNAL" in load_messages:
                    raise Exception(f"Failed to load Monday updates to {stage_table}: {load_messages}")
                total_updates += len(page_records)

            logger.info(
                f"Project {project_id}: page {page_number} scanned {len(items)} item(s), staged {len(page_records)} event(s)"
            )

            cursor_value = items_page.get("cursor")
            if not cursor_value:
                break
            time.sleep(1)

        extraction_end = datetime.now(timezone.utc)
        watermark_dt = max(max_seen_item_updated_at, max_seen_event_at)
        if total_items > 0 and watermark_dt and watermark_dt > last_fetch_dt:
            control_result = load_control_table(
                extraction_start.strftime("%Y-%m-%dT%H%M%S"),
                format_timestamp(last_fetch_dt),
            format_timestamp(watermark_dt),
                extraction_start.strftime("%Y-%m-%dT%H%M%S"),
                extraction_end.strftime("%Y-%m-%dT%H%M%S"),
                stage_table,
                'NA',
                total_updates,
                schema,
                db,
            )
            if not control_result["status"]:
                raise Exception(f"Control table update failed for {stage_table}: {control_result['message']}")

        return {
            "status": "SUCCESS",
            "project_id": project_id,
            "board_id": board_id,
            "table": stage_table,
            "items_scanned": total_items,
            "updates_staged": total_updates,
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
                "updates_staged": 0,
                "results": [],
            }

        results = []
        total_updates = 0
        for project in monday_projects:
            try:
                result = process_project(project, db)
            except Exception as exc:
                logger.error(f"Failed to fetch Monday updates for {project.get('id')}: {exc}")
                result = {
                    "status": "FAILED",
                    "project_id": project.get("id"),
                    "board_id": project.get("WorkItemDetails", {}).get("MondayConn", {}).get("BOARD_ID"),
                    "table": get_updates_stage_table_name(
                        project.get("WorkItemDetails", {}).get("SnowflakeConn", {}).get("SNOWFLAKE_TABLE_NAME", "")
                    ),
                    "items_scanned": 0,
                    "updates_staged": 0,
                    "error": str(exc),
                }
            results.append(result)
            if result["status"] == "SUCCESS":
                total_updates += result.get("updates_staged", 0)

        failures = [result for result in results if result["status"] != "SUCCESS"]
        summary = {
            "status": "FAILED" if failures else "SUCCESS",
            "projects_total": len(monday_projects),
            "projects_loaded": len(results) - len(failures),
            "projects_failed": len(failures),
            "updates_staged": total_updates,
            "results": results,
        }
        return summary
    except Exception as exc:
        logger.error(f"Critical error in Monday updates fetch: {exc}")
        return {
            "status": "FAILED",
            "projects_total": 0,
            "projects_loaded": 0,
            "projects_failed": 0,
            "updates_staged": 0,
            "results": [],
            "error": str(exc),
        }


if __name__ == "__main__":
    result = main(item_ids=sys.argv[1:] if len(sys.argv) > 1 else None)
    sys.exit(0 if result.get("status") == "SUCCESS" else 1)