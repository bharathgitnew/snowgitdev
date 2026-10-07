import json
import re
import requests
import time
import os
import sys
from datetime import datetime
import logging

from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_result, retry_if_exception_type, before_sleep_log

from include.Python.TELTools import (
    getAzureSecret,
    getSnowFlakeConn,
    load_config,
    load_control_table,
    read_runtime_config
)

logger = logging.getLogger(__name__)
if not logger.handlers:
    handler = logging.StreamHandler()
    handler.setFormatter(logging.Formatter('%(asctime)s %(levelname)s - %(message)s', '%Y-%m-%d %H:%M:%S'))
    logger.addHandler(handler)
logger.setLevel(logging.INFO)

logging.getLogger('azure').setLevel(logging.WARNING)
logging.getLogger('snowflake.connector').setLevel(logging.WARNING)

HTTP_TIMEOUT = 60


def validate_monday_connection_config(monday_conn, project_id):
    if not isinstance(monday_conn, dict):
        raise ValueError(f"{project_id}: missing MondayConn configuration")

    board_id = str(monday_conn.get("BOARD_ID", "")).strip()
    if not board_id:
        raise ValueError(f"{project_id}: MondayConn.BOARD_ID is required")

    api_key_secret_name = str(monday_conn.get("api_key", "")).strip()
    if not api_key_secret_name:
        raise ValueError(f"{project_id}: MondayConn.api_key is required")


def resolve_monday_api_key(api_key_secret_name, project_id):
    api_key_secret_name = str(api_key_secret_name or "").strip()
    if not api_key_secret_name:
        raise ValueError(f"{project_id}: MondayConn.api_key is required")

    return getAzureSecret(api_key_secret_name).value


def _is_status_failed(result):
    return isinstance(result, dict) and not result.get('status', True)


_api_retry = retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=2, max=30),
    retry=retry_if_result(_is_status_failed) | retry_if_exception_type(requests.exceptions.RequestException),
    before_sleep=before_sleep_log(logger, logging.WARNING),
    reraise=True,
)

_snowflake_retry = retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=3, max=60),
    retry=retry_if_result(_is_status_failed),
    before_sleep=before_sleep_log(logger, logging.WARNING),
    reraise=True,
)

API_URL = "https://api.monday.com/v2"

DEFAULT_WORK_ITEM_CONFIG_PATH = '/usr/local/airflow/include/Configuration/TelTools_AzureDevops_Monday.json'
LOCAL_WORK_ITEM_CONFIG_PATH = os.path.abspath(
    os.path.join(os.path.dirname(__file__), '..', 'Configuration', 'TelTools_AzureDevops_Monday.json')
)
WORK_ITEM_CONFIG_PATH = os.environ.get('TELTOOLS_AZURE_DEVOPS_CONFIG_PATH', DEFAULT_WORK_ITEM_CONFIG_PATH)
if not os.path.exists(WORK_ITEM_CONFIG_PATH):
    WORK_ITEM_CONFIG_PATH = LOCAL_WORK_ITEM_CONFIG_PATH

BATCH_SIZE = 8

# Must match board creator's clean_column_name() exactly
PREFIXES = [
    "Microsoft.VSTS.Scheduling.",
    "Microsoft.VSTS.Common.",
    "Microsoft.VSTS.TCM.",
    "Microsoft.VSTS.Build.",
    "Microsoft.VSTS.CMMI.",
    "FSI.WorkItem.",
    "Install.",
    "System.",
]


def clean_column_name(field_name):
    name = field_name
    for prefix in PREFIXES:
        if name.startswith(prefix):
            name = name[len(prefix):]
            break

    result = []
    for i, char in enumerate(name):
        if i > 0 and char.isupper() and name[i - 1].islower():
            result.append(" ")
        result.append(char)

    name = "".join(result)
    name = name.replace(".", " ").replace("_", " ")
    name = " ".join(name.split())
    return name.title()



def fetch_data_from_table(conn, table_name, last_run_date=None):
    try:
        cursor = conn.cursor()
        query = f"SELECT JSONFIELD FROM {table_name}"
        if last_run_date:
            query += f" WHERE TO_TIMESTAMP(_UPLOADDATE) >= '{last_run_date}'::TIMESTAMP"
        cursor.execute(query)
        rows = cursor.fetchall()
        cursor.close()

        items = []
        for row in rows:
            json_str = row[0]
            item = json.loads(json_str) if isinstance(json_str, str) else json_str
            items.append(item)
        return items
    except Exception as e:
        logger.error(f"Error fetching data from {table_name}: {e}")
        raise



def execute_graphql(query, variables=None, api_key=None):
    headers = {
        "Authorization": api_key,
        "Content-Type": "application/json"
    }
    payload = {"query": query}
    if variables:
        payload["variables"] = variables

    response = requests.post(API_URL, json=payload, headers=headers, timeout=HTTP_TIMEOUT)

    if response.status_code == 429:
        wait = int(response.headers.get("Retry-After", 15))
        logger.warning(f"Rate limited. Waiting {wait}s...")
        time.sleep(wait)
        raise requests.exceptions.RequestException(f"Rate limited (429), waited {wait}s")

    if response.status_code != 200:
        raise Exception(f"API Error {response.status_code}: {response.text[:200]}")

    result = response.json()

    if "errors" in result:
        error_msg = str(result["errors"])
        if "complexity" in error_msg.lower() or "rate" in error_msg.lower():
            logger.warning("Complexity/rate limit hit. Waiting 15s...")
            time.sleep(15)
            raise requests.exceptions.RequestException(f"Complexity/rate limit: {error_msg[:100]}")
        raise Exception(f"GraphQL Error: {result['errors']}")

    return result.get("data", {})


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
    data = _api_retry(execute_graphql)(query, {"boardId": [board_id]}, api_key=api_key)
    boards = data.get("boards", [])
    return boards[0].get("columns", []) if boards else []


def get_existing_items(board_id, work_item_id_col_id, api_key):
    # First page has no cursor
    query_first = """
    query ($boardId: [ID!]!, $colId: [String!]) {
      boards(ids: $boardId) {
        items_page(limit: 500) {
          cursor
          items {
            id
            column_values(ids: $colId) { id text }
          }
        }
      }
    }
    """
    query_next = """
        query ($cursor: String!, $colId: [String!]) {
      next_items_page(limit: 500, cursor: $cursor) {
        cursor
        items {
          id
                    column_values(ids: $colId) { id text }
        }
      }
    }
    """

    def get_matching_text(column_values):
        for column in column_values or []:
            if column.get("id") == work_item_id_col_id and column.get("text"):
                return column["text"]
        return None

    lookup = {}
    data = _api_retry(execute_graphql)(
        query_first, {"boardId": [board_id], "colId": [work_item_id_col_id]}, api_key=api_key
    )

    boards = data.get("boards", [])
    if not boards:
        return lookup

    page = boards[0].get("items_page", {})
    for item in page.get("items", []):
        work_item_text = get_matching_text(item.get("column_values", []))
        if work_item_text:
            lookup[work_item_text] = item["id"]

    cursor = page.get("cursor")
    while cursor:
        data = _api_retry(execute_graphql)(
            query_next,
            {"cursor": cursor, "colId": [work_item_id_col_id]},
            api_key=api_key,
        )
        page = data.get("next_items_page", {})
        for item in page.get("items", []):
            work_item_text = get_matching_text(item.get("column_values", []))
            if work_item_text:
                lookup[work_item_text] = item["id"]
        cursor = page.get("cursor")

    return lookup


def batch_create_items(board_id, items_data, api_key):
    if not items_data:
        return []

    mutation_parts = []
    variables = {}

    for idx, (item_name, column_values) in enumerate(items_data):
        alias = f"item_{idx}"
        var_name = f"name_{idx}"
        var_cols = f"cols_{idx}"

        mutation_parts.append(
            f'{alias}: create_item('
            f'board_id: "{board_id}", '
            f'item_name: ${var_name}, '
            f'column_values: ${var_cols}'
            f') {{ id name }}'
        )

        variables[var_name] = item_name
        variables[var_cols] = json.dumps(column_values)

    var_declarations = []
    for idx in range(len(items_data)):
        var_declarations.append(f"$name_{idx}: String!")
        var_declarations.append(f"$cols_{idx}: JSON!")

    query = f"mutation ({', '.join(var_declarations)}) {{\n  " + "\n  ".join(mutation_parts) + "\n}"

    data = _api_retry(execute_graphql)(query, variables, api_key=api_key)

    results = []
    for idx in range(len(items_data)):
        alias = f"item_{idx}"
        results.append(data.get(alias, {}))

    return results


def batch_update_items(board_id, items_data, api_key):
    if not items_data:
        return []

    mutation_parts = []
    variables = {}

    for idx, (monday_item_id, column_values) in enumerate(items_data):
        alias = f"item_{idx}"
        var_cols = f"cols_{idx}"

        mutation_parts.append(
            f'{alias}: change_multiple_column_values('
            f'item_id: {monday_item_id}, '
            f'board_id: "{board_id}", '
            f'column_values: ${var_cols}'
            f') {{ id }}'
        )

        variables[var_cols] = json.dumps(column_values)

    var_declarations = []
    for idx in range(len(items_data)):
        var_declarations.append(f"$cols_{idx}: JSON!")

    query = f"mutation ({', '.join(var_declarations)}) {{\n  " + "\n  ".join(mutation_parts) + "\n}"

    data = _api_retry(execute_graphql)(query, variables, api_key=api_key)

    results = []
    for idx in range(len(items_data)):
        alias = f"item_{idx}"
        results.append(data.get(alias, {}))

    return results



def create_column_mapping(all_field_names, monday_columns):
    columns_by_title = {col["title"]: col for col in monday_columns}
    mapping = {}

    for azure_field in all_field_names:
        if azure_field == "System.Title":
            continue
        column_name = clean_column_name(azure_field)
        if column_name in columns_by_title:
            monday_col = columns_by_title[column_name]
            mapping[azure_field] = {
                "column_id": monday_col["id"],
                "column_type": monday_col["type"],
                "column_title": monday_col["title"]
            }

    top_level_map = {
        "_top_level.id":  "Work Item Id",
        "_top_level.rev": "Revision",
        "_top_level.url": "Work Item Url",
    }
    for key, title in top_level_map.items():
        if title in columns_by_title:
            monday_col = columns_by_title[title]
            mapping[key] = {
                "column_id": monday_col["id"],
                "column_type": monday_col["type"],
                "column_title": monday_col["title"]
            }

    return mapping



def transform_date(azure_date):
    if not azure_date:
        return None
    try:
        dt = datetime.fromisoformat(str(azure_date).replace('Z', '+00:00'))
        return dt.strftime("%Y-%m-%d")
    except Exception:
        return None


def transform_value_for_monday(field_value, column_type):
    if field_value is None:
        return None

    if column_type == "date":
        date_str = transform_date(field_value)
        return {"date": date_str} if date_str else None

    # Azure identity objects -> extract displayName
    if isinstance(field_value, dict) and "displayName" in field_value:
        return field_value.get("displayName", "")

    if column_type == "numeric":
        try:
            return str(field_value)
        except Exception:
            return None

    if column_type == "long_text":
        text = str(field_value)
        clean = re.sub(r'<[^>]+>', '', text)
        return {"text": clean} if clean.strip() else None

    if isinstance(field_value, str):
        return field_value

    return str(field_value)


def prepare_item_data(azure_item, column_mapping):
    fields = azure_item.get("fields", {})
    item_name = fields.get("System.Title", f"Item {azure_item.get('id', '')}")
    column_values = {}

    for azure_field, field_value in fields.items():
        if azure_field == "System.Title":
            continue
        if azure_field not in column_mapping:
            continue

        col_info = column_mapping[azure_field]
        transformed = transform_value_for_monday(field_value, col_info["column_type"])

        if transformed is not None:
            column_values[col_info["column_id"]] = transformed

    top_level_fields = {
        "_top_level.id":  azure_item.get("id"),
        "_top_level.rev": azure_item.get("rev"),
        "_top_level.url": azure_item.get("url"),
    }
    for key, value in top_level_fields.items():
        if value is not None and key in column_mapping:
            col_info = column_mapping[key]
            transformed = transform_value_for_monday(value, col_info["column_type"])
            if transformed is not None:
                column_values[col_info["column_id"]] = transformed

    return item_name, column_values



def load_project(conn, project_id, table_name, board_id, schema, db, api_key):
    logger.info("=" * 70)
    logger.info(f"Project: {project_id}")
    logger.info(f"Table: {table_name}  |  Board ID: {board_id}")
    logger.info("=" * 70)

    monday_table_key = f"MONDAY_{table_name}"

    try:
        runtime_result = read_runtime_config(db, schema)
        last_run_date = None
        if runtime_result['status'] and runtime_result['data']:
            tbl_last_run = runtime_result['data'].get(monday_table_key)
            if tbl_last_run:
                last_run_date = datetime.strptime(str(tbl_last_run), "%Y-%m-%dT%H%M%S")

        if last_run_date:
            logger.info(f"Incremental load since: {last_run_date}")
        else:
            logger.info("Full load (no previous run found)")

        items = fetch_data_from_table(conn, table_name, last_run_date)
        if not items:
            logger.info("No new data to process")
            return {
                "status": "SUCCESS", "project_id": project_id, "board_id": board_id,
                "table": table_name, "items_created": 0, "items_updated": 0,
                "items_failed": 0, "total_items": 0
            }
        logger.info(f"{len(items)} work items fetched")

        monday_columns = get_board_columns(board_id, api_key)
        logger.info(f"{len(monday_columns)} columns on board")

        # Scan all items so we map every possible field, not just the first item's fields
        all_fields = set()
        for item in items:
            all_fields.update(item.get("fields", {}).keys())

        column_mapping = create_column_mapping(all_fields, monday_columns)
        logger.info(f"{len(column_mapping)} fields mapped")

        unmapped = []
        for f in all_fields:
            if f != "System.Title" and f not in column_mapping:
                unmapped.append(f)
        if unmapped:
            logger.warning(f"{len(unmapped)} unmapped (excluded or no column):")
            for f in sorted(unmapped)[:10]:
                logger.warning(f"  - {f} -> {clean_column_name(f)}")

        logger.info("Preparing items...")
        prepared = []
        for azure_item in items:
            item_name, column_values = prepare_item_data(azure_item, column_mapping)
            prepared.append((item_name, column_values))

        # Fetch existing items from Monday to decide create vs update
        work_item_id_col = column_mapping.get("_top_level.id", {}).get("column_id")
        existing_items = {}
        if work_item_id_col:
            logger.info("Scanning Monday board for existing items...")
            existing_items = get_existing_items(board_id, work_item_id_col, api_key)
            logger.info(f"{len(existing_items)} existing items on board")

        to_create = []
        to_update = []
        for idx, (item_name, column_values) in enumerate(prepared):
            azure_id = str(items[idx].get("id", ""))
            if azure_id in existing_items:
                to_update.append((existing_items[azure_id], column_values))
            else:
                to_create.append((item_name, column_values))

        logger.info(f"To create: {len(to_create)}, To update: {len(to_update)}")

        created = 0
        updated = 0
        failed_items = 0

        # Batch create new items
        if to_create:
            logger.info(f"Creating {len(to_create)} new items in batches of {BATCH_SIZE}...")
            total_batches = (len(to_create) + BATCH_SIZE - 1) // BATCH_SIZE
            for batch_num in range(total_batches):
                start = batch_num * BATCH_SIZE
                end = min(start + BATCH_SIZE, len(to_create))
                batch = to_create[start:end]

                try:
                    results = batch_create_items(board_id, batch, api_key)
                    batch_success = sum(1 for r in results if r.get("id"))
                    batch_fail = len(batch) - batch_success
                    created += batch_success
                    failed_items += batch_fail

                    pct = (end / len(to_create)) * 100
                    logger.info(f"Create {batch_num + 1:3}/{total_batches} "
                                f"[{end:4}/{len(to_create)}] ({pct:5.1f}%) "
                                f"success={batch_success}"
                                f"{f' failed={batch_fail}' if batch_fail else ''}")
                    time.sleep(1.5)

                except Exception as e:
                    failed_items += len(batch)
                    logger.error(f"Create batch {batch_num + 1}/{total_batches} FAILED: {str(e)[:60]}")

                    # Complexity error -> fall back to one-at-a-time so we don't lose the entire batch
                    if "complexity" in str(e).lower():
                        logger.warning("Retrying items individually...")
                        time.sleep(15)
                        for item_name, col_vals in batch:
                            try:
                                single_result = batch_create_items(board_id, [(item_name, col_vals)], api_key)
                                if single_result and single_result[0].get("id"):
                                    created += 1
                                    failed_items -= 1
                                time.sleep(0.5)
                            except Exception:
                                pass

        # Batch update existing items
        if to_update:
            logger.info(f"Updating {len(to_update)} existing items in batches of {BATCH_SIZE}...")
            total_batches = (len(to_update) + BATCH_SIZE - 1) // BATCH_SIZE
            for batch_num in range(total_batches):
                start = batch_num * BATCH_SIZE
                end = min(start + BATCH_SIZE, len(to_update))
                batch = to_update[start:end]

                try:
                    results = batch_update_items(board_id, batch, api_key)
                    batch_success = sum(1 for r in results if r.get("id"))
                    batch_fail = len(batch) - batch_success
                    updated += batch_success
                    failed_items += batch_fail

                    pct = (end / len(to_update)) * 100
                    logger.info(f"Update {batch_num + 1:3}/{total_batches} "
                                f"[{end:4}/{len(to_update)}] ({pct:5.1f}%) "
                                f"success={batch_success}"
                                f"{f' failed={batch_fail}' if batch_fail else ''}")
                    time.sleep(1.5)

                except Exception as e:
                    failed_items += len(batch)
                    logger.error(f"Update batch {batch_num + 1}/{total_batches} FAILED: {str(e)[:60]}")

        logger.info(f"Created: {created}, Updated: {updated}, Failed: {failed_items}")

        if failed_items > 0:
            error_message = f"{failed_items} item(s) failed during Monday sync"
            logger.error(error_message)
            return {
                "status": "FAILED",
                "project_id": project_id,
                "board_id": board_id,
                "table": table_name,
                "error": error_message,
                "items_created": created,
                "items_updated": updated,
                "items_failed": failed_items,
                "total_items": len(items)
            }

        batch_datetimestamp = datetime.now()
        current_timestamp = str(batch_datetimestamp).replace(" ", "_").replace(":", "_").replace(".", "_")
        batch_end = datetime.strftime(datetime.now(), "%Y-%m-%dT%H%M%S")

        control_result = _snowflake_retry(load_control_table)(
            current_timestamp,
            str(last_run_date) if last_run_date else None,
            batch_end,
            datetime.strftime(batch_datetimestamp, "%Y-%m-%dT%H%M%S"),
            batch_end,
            monday_table_key,
            'NA',
            created + updated,
            schema,
            db
        )
        logger.info(f"Control table result: {control_result}")

        if not control_result['status']:
            error_message = f"Control table update failed: {control_result['message']}"
            logger.error(error_message)
            return {
                "status": "FAILED",
                "project_id": project_id,
                "board_id": board_id,
                "table": table_name,
                "error": error_message,
                "items_created": created,
                "items_updated": updated,
                "items_failed": failed_items,
                "total_items": len(items)
            }

        return {
            "status": "SUCCESS",
            "project_id": project_id,
            "board_id": board_id,
            "table": table_name,
            "items_created": created,
            "items_updated": updated,
            "items_failed": failed_items,
            "total_items": len(items)
        }

    except Exception as e:
        logger.error(f"FAILED: {str(e)}")
        return {
            "status": "FAILED",
            "project_id": project_id,
            "board_id": board_id,
            "table": table_name,
            "error": str(e),
            "items_created": 0,
            "items_updated": 0,
            "items_failed": 0,
            "total_items": 0
        }



def main(item_ids=None):
    try:
        db = os.environ["SNOWFLAKE_LZ"]

        logger.info("=" * 60)
        logger.info("SNOWFLAKE -> MONDAY.COM BATCH DATA LOADER")
        logger.info(f"Batch size: {BATCH_SIZE} items per API call")
        logger.info("=" * 60)

        cfg_result = load_config(WORK_ITEM_CONFIG_PATH)
        if not cfg_result['status']:
            raise Exception(cfg_result['message'])
        config = cfg_result['data']

        projects = config.get("WorkItems", [])
        enabled = [p for p in projects if p.get("enabled", True)]

        if item_ids:
            item_ids = [item_id.upper() for item_id in item_ids]
            enabled = [p for p in enabled if p.get("id", "").upper() in item_ids]

        # Only process projects that have a MondayConn config
        monday_projects = [p for p in enabled if p.get("WorkItemDetails", {}).get("MondayConn")]

        if item_ids and not monday_projects:
            logger.info(f"No Monday-enabled projects selected for item IDs: {', '.join(item_ids)}")
            return {
                "status": "SUCCESS",
                "projects_total": 0,
                "projects_loaded": 0,
                "projects_failed": 0,
                "items_created": 0,
                "items_updated": 0,
                "results": [],
            }

        for p in monday_projects:
            monday_conn = p["WorkItemDetails"]["MondayConn"]
            validate_monday_connection_config(monday_conn, p["id"])

        skipped = [p['id'] for p in enabled if p not in monday_projects]
        if skipped:
            logger.info(f"Skipping {len(skipped)} project(s) without MondayConn: {', '.join(skipped)}")

        logger.info(f"Projects: {len(monday_projects)}")
        for p in monday_projects:
            table = p["WorkItemDetails"]["SnowflakeConn"]["SNOWFLAKE_TABLE_NAME"]
            board = p["WorkItemDetails"]["MondayConn"]["BOARD_ID"]
            logger.info(f"  {p['id']:20} {table:20} -> Board: {board}")

        start_time = time.time()
        results = []

        for i, project in enumerate(monday_projects, 1):
            project_id = project["id"]
            sf_config = project["WorkItemDetails"]["SnowflakeConn"]
            monday_conn = project["WorkItemDetails"]["MondayConn"]

            table_name = sf_config["SNOWFLAKE_TABLE_NAME"]
            schema = sf_config["SNOWFLAKE_SCHEMA_NAME"]
            board_id = monday_conn["BOARD_ID"]

            api_key = resolve_monday_api_key(monday_conn.get("api_key"), project_id)

            # Per-project connection because schema may differ between projects
            messages = []
            conn, messages = getSnowFlakeConn(db, schema, messages)
            if conn == 'no connection':
                logger.error(f"Snowflake connection failed for {project_id}: {messages}")
                results.append({
                    "status": "FAILED", "project_id": project_id, "board_id": board_id,
                    "table": table_name, "error": f"Snowflake connection failed: {messages}",
                    "items_created": 0, "items_failed": 0, "total_items": 0
                })
                continue

            logger.info(f"[{i}/{len(monday_projects)}] Processing {project_id}")
            try:
                result = load_project(conn, project_id, table_name, board_id, schema, db, api_key)
                results.append(result)
            finally:
                conn.close()

            if i < len(monday_projects):
                time.sleep(2)

        elapsed = time.time() - start_time

        successful = [r for r in results if r["status"] == "SUCCESS"]
        failed = [r for r in results if r["status"] == "FAILED"]
        total_created = sum(r.get("items_created", 0) for r in successful)
        total_updated = sum(r.get("items_updated", 0) for r in successful)

        logger.info("=" * 60)
        logger.info("SUMMARY")
        logger.info("=" * 60)
        logger.info(f"Elapsed: {elapsed:.0f}s ({elapsed/60:.1f} min)")
        logger.info(f"Boards: {len(successful)} loaded, {len(failed)} failed")
        logger.info(f"Items: {total_created} created, {total_updated} updated")

        total_processed = total_created + total_updated
        if total_processed > 0 and elapsed > 0:
            logger.info(f"Throughput: {total_processed/elapsed:.1f} items/sec")

        for r in successful:
            logger.info(f"  {r['project_id']:20} created={r.get('items_created',0)} updated={r.get('items_updated',0)}")

        for r in failed:
            logger.error(f"  {r['project_id']:20} - {r.get('error', '?')[:50]}")

        logger.info("=" * 60)

        summary = {
            "status": "SUCCESS",
            "projects_total": len(monday_projects),
            "projects_loaded": len(successful),
            "projects_failed": len(failed),
            "items_created": total_created,
            "items_updated": total_updated,
            "results": results,
        }

        if failed:
            logger.error(f"Pipeline completed with {len(failed)} failure(s)")
            summary["status"] = "FAILED"
        else:
            logger.info("Pipeline completed successfully")

        return summary

    except Exception as e:
        logger.error(f"Critical error in main function: {str(e)}")
        return {
            "status": "FAILED",
            "projects_total": 0,
            "projects_loaded": 0,
            "projects_failed": 0,
            "items_created": 0,
            "items_updated": 0,
            "results": [],
            "error": str(e),
        }


if __name__ == "__main__":
    result = main(item_ids=sys.argv[1:] if len(sys.argv) > 1 else None)
    sys.exit(0 if result.get("status") == "SUCCESS" else 1)