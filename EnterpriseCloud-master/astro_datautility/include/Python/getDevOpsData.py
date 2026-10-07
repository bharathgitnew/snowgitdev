import base64
import json
import logging
import os
import sys
from datetime import date, datetime

import requests

import include.Python.TELTools as TT


logger = logging.getLogger(__name__)
if not logger.handlers:
    handler = logging.StreamHandler()
    handler.setFormatter(logging.Formatter('%(asctime)s %(levelname)s - %(message)s', '%Y-%m-%d %H:%M:%S'))
    logger.addHandler(handler)
logger.setLevel(logging.INFO)

logging.getLogger('azure').setLevel(logging.WARNING)
logging.getLogger('snowflake.connector').setLevel(logging.WARNING)

HTTP_TIMEOUT = 60
LZ_DB = os.environ["SNOWFLAKE_LZ"]
DATABASE_NAME = os.getenv('SNOWFLAKE_LZ')

LOCAL_WORK_ITEM_CONFIG_PATH = os.path.abspath(
    os.path.join(os.path.dirname(__file__), '..', 'Configuration', 'TelTools_AzureDevops_Monday.json')
)



def getWorkItemConfig(item_ids=None):
    with open(LOCAL_WORK_ITEM_CONFIG_PATH, 'r', encoding='utf-8') as file_handle:
        config_json = json.load(file_handle, strict=False)

    work_items = config_json.get('WorkItems', [])
    work_items = [item for item in work_items if item.get('enabled', True)]

    if item_ids:
        requested_ids = {item_id.upper() for item_id in item_ids}
        filtered_items = [item for item in work_items if item.get('id', '').upper() in requested_ids]
        if not filtered_items:
            raise Exception(f"None of the requested work items found or disabled: {sorted(requested_ids)}")
        return filtered_items

    return work_items


def readControlTable(sf_schema, table_name):
    messages = []
    conn, messages = TT.getSnowFlakeConn(LZ_DB, sf_schema, messages)
    if conn == 'no connection':
        return {"status": False, "last_run_time": None, "message": messages}

    try:
        cursor = conn.cursor()
        query = (
            f"select INCREMENTAL_END_VALUE from {LZ_DB}.{sf_schema}.CONTROLTABLE "
            f"WHERE TABLE_NAME='{table_name}' order by RUN_TIME desc limit 1"
        )
        cursor.execute(query)
        results = cursor.fetchall()
        values = [row[0] for row in results]
        last_run_time = values[0] if values else None
        messages.append(
            f"readControlTable(): Read from snowflake completed for {LZ_DB}, {sf_schema}"
        )
        return {"status": True, "last_run_time": last_run_time, "message": messages}
    except Exception as exc:
        messages.append('FAIL_SIGNAL')
        messages.append(
            f"Read Data: Read from snowflake failed for {LZ_DB}, {sf_schema}, {table_name}: {exc}"
        )
        return {"status": False, "last_run_time": None, "message": messages}
    finally:
        conn.close()


def update_control_table(
    current_timestamp,
    incremental_start_value,
    incremental_end_value,
    extraction_start_time,
    extraction_end_time,
    table_name,
    max_file_date,
    rows_loaded,
    schema,
):
    try:
        messages = TT.loadControlTable(
            LZ_DB,
            schema,
            current_timestamp,
            incremental_start_value,
            incremental_end_value,
            extraction_start_time,
            extraction_end_time,
            table_name,
            max_file_date,
            rows_loaded,
        )
        if 'FAIL_SIGNAL' in messages:
            return {"status": False, "message": messages}
        return {"status": True, "message": messages}
    except Exception as exc:
        return {"status": False, "message": f"Error in update_control_table {table_name}: {exc}"}


def build_headers(pat):
    encoded_pat = base64.b64encode(bytes(':' + pat, 'utf-8')).decode('ascii')
    return {
        'Authorization': 'Basic ' + encoded_pat,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
    }


def build_wiql_query(project_filter, last_run_date):
    conditions = []
    if project_filter:
        conditions.append(f"[System.TeamProject] = '{project_filter}'")

    if last_run_date is None:
        conditions.append(f"[System.ChangedDate] <= '{date.today().isoformat()} GMT'")
    else:
        conditions.append(f"[System.ChangedDate] >= '{last_run_date.isoformat()} GMT'")

    return "Select * From WorkItems WHERE " + " AND ".join(conditions)


def get_Data(org_url, work_item_site, project_filter, pat, last_run_date):
    extract_datetimestamp = datetime.now()
    headers = build_headers(pat)
    payload = json.dumps({"query": build_wiql_query(project_filter, last_run_date)})

    response = requests.post(
        f"{org_url}/{work_item_site}",
        headers=headers,
        data=payload,
        verify=False,
        timeout=HTTP_TIMEOUT,
    )
    response.raise_for_status()
    detailed_items = response.json()

    data = []
    for work_item in detailed_items.get('workItems', []):
        work_item_id = work_item['id']
        detail_url = f"{org_url}/_apis/wit/workitems/{work_item_id}?api-version=7.1-preview.3"
        detail_response = requests.get(
            detail_url,
            headers=headers,
            verify=False,
            timeout=HTTP_TIMEOUT,
        )
        detail_response.raise_for_status()
        data.append(detail_response.json())

    return extract_datetimestamp, data, len(data)


def load_Data(org_url, work_item_site, project_filter, pat, sf_schema_name, sf_table_name, last_run_date):
    extract_datetimestamp, dataset, record_count = get_Data(
        org_url,
        work_item_site,
        project_filter,
        pat,
        last_run_date,
    )

    logger.info(f"Records extracted from azure devops: {record_count}")

    file_name = 'Work_Items_' + datetime.strftime(extract_datetimestamp, "%Y-%m-%dT%H%M%S") + '.json'
    run_name = datetime.strftime(extract_datetimestamp, "%Y-%m-%dT%H%M%S")

    try:
        return_messages = TT.putSnowflakeDataFrame(
            DATABASE_NAME,
            sf_schema_name,
            sf_table_name,
            dataset,
            file_name,
            extract_datetimestamp,
            record_count,
        )
        logger.info(f"Snowflake load messages: {return_messages}")
        if 'FAIL_SIGNAL' in return_messages:
            raise Exception(f"Snowflake load returned FAIL_SIGNAL: {return_messages}")
    except Exception as exc:
        logger.error(f"Error in ingesting data to {sf_table_name}: {exc}")
        return {"status": False, "record_count": 0, "run_name": run_name, "message": str(exc)}

    return {"status": True, "record_count": record_count, "run_name": run_name, "message": return_messages}


def process_work_item(work_item):
    project_id = work_item.get('id', '')
    work_item_details = work_item.get('WorkItemDetails', {})
    site_config = work_item_details.get('SiteConfig', {})
    sf_config = work_item_details.get('SnowflakeConn', {})

    org_url = site_config.get('org_url')
    work_item_site = site_config.get('work_item_site')
    pat_secret_name = site_config.get('pat')
    project_filter = site_config.get('project_filter')
    sf_schema_name = sf_config.get('SNOWFLAKE_SCHEMA_NAME')
    sf_table_name = sf_config.get('SNOWFLAKE_TABLE_NAME')

    logger.info(f"--- Processing Work Item: {project_id} ---")
    logger.info(f"Table: {sf_table_name}")
    if project_filter:
        logger.info(f"Project Filter: {project_filter}")

    control_result = readControlTable(sf_schema_name, sf_table_name)
    if not control_result['status']:
        logger.error(f"Error reading control table for {project_id}: {control_result['message']}")
        return {"item_id": project_id, "status": "failed", "error": "Unable to read from Control Table"}

    last_run_value = control_result['last_run_time']
    last_run_date = None
    if last_run_value is not None:
        last_run_date = datetime.strptime(last_run_value, "%Y-%m-%dT%H%M%S").date()

    logger.info(f"Read Controltable result-message: {control_result['message']}")
    logger.info(f"Last Run Date is: {last_run_date}")

    pat = TT.getAzureSecret(pat_secret_name).value
    load_result = load_Data(
        org_url,
        work_item_site,
        project_filter,
        pat,
        sf_schema_name,
        sf_table_name,
        last_run_date,
    )
    if not load_result['status']:
        return {
            "item_id": project_id,
            "status": "failed",
            "error": "Failed to load data from Azure DevOps or ingest to Snowflake",
        }

    logger.info("Updating Metadata")
    current_timestamp = datetime.strftime(datetime.now(), "%Y-%m-%dT%H%M%S")
    extraction_start_time = current_timestamp
    extraction_end_time = datetime.strftime(datetime.now(), "%Y-%m-%dT%H%M%S")
    update_result = update_control_table(
        current_timestamp,
        last_run_value,
        load_result['run_name'],
        extraction_start_time,
        extraction_end_time,
        sf_table_name,
        'NA',
        load_result['record_count'],
        sf_schema_name,
    )
    logger.info(f"Control table result: {update_result}")
    if not update_result['status']:
        return {
            "item_id": project_id,
            "status": "failed",
            "error": f"Control table update failed: {update_result['message']}",
        }

    return {"item_id": project_id, "status": "success", "rows": load_result['record_count']}


def main(item_ids=None):
    work_items = getWorkItemConfig(item_ids=item_ids)
    logger.info(f"Processing {len(work_items)} work item(s)")

    results = []
    total_rows = 0
    for work_item in work_items:
        result = process_work_item(work_item)
        results.append(result)
        if result['status'] == 'success':
            total_rows += result.get('rows', 0)
        else:
            logger.error(f"Error processing work item {work_item.get('id')}: {result.get('error')}")

    successful = [result for result in results if result['status'] == 'success']
    failed = [result for result in results if result['status'] == 'failed']

    logger.info("=== Summary ===")
    for result in successful:
        logger.info(f"Item {result['item_id']}: success ({result.get('rows', 0)} rows)")
    for result in failed:
        logger.error(f"Item {result['item_id']}: failed - Error: {result.get('error')}")
    logger.info(f"Total: {len(work_items)} work item(s) processed")
    logger.info(f"Successful: {len(successful)}")
    logger.info(f"Failed: {len(failed)}")

    overall_status = 'SUCCESS' if not failed else 'FAILED'
    if overall_status == 'SUCCESS':
        logger.info("Pipeline completed successfully")
    else:
        logger.error(f"Pipeline completed with {len(failed)} failure(s)")

    return {
        "status": overall_status,
        "processed": len(work_items),
        "successful": len(successful),
        "failed": len(failed),
        "total_rows": total_rows,
        "results": results,
    }


if __name__ == "__main__":
    result = main(item_ids=sys.argv[1:] if len(sys.argv) > 1 else None)
    sys.exit(0 if result.get("status") == "SUCCESS" else 1)
