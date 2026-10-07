"""
ServiceNow Data Extraction Module

This module provides functionality to extract data from ServiceNow API and load it to Snowflake.
"""

from include.Python.TELTools import getAzureSecret, putSnowflakeDataFrame, readControlTable, loadControlTable
from datetime import datetime
import pytz
import json
import os
import requests
from requests.auth import HTTPBasicAuth
import sys

FILEDATE = datetime.now(tz=pytz.timezone('America/Chicago'))
LZ_DB = os.environ["SNOWFLAKE_LZ"]
RUN_TIME = str(FILEDATE).replace(" ", "_").replace(":", "_").replace(".", "_")
script_dir = os.path.dirname(__file__)
CONN_CONFIG_PATH = os.path.abspath(os.path.join(script_dir, "..", "Configuration", "TelTools_ServiceNow.json"))


def requestServiceNowData(tgt_schema, base_url, auth, section):
    """
    Handle incremental ServiceNow API call.
    Used for incremental data extraction based on control table.

    Args:
        tgt_schema (str): Target schema
        base_url (str): Base URL
        auth (tuple): Authentication tuple
        section (dict): Section/resource configuration
    """
    # Extract configuration values directly
    table_name = section.get("table_name")
    query = section.get("query")
    fields = section.get("fields")
    tgt_table = section.get("sf_table")
    extraction_Start_Time = str(datetime.now()).replace(" ", "_").replace(":", "_").replace(".", "_")
    print(f"requestServiceNowData starting for {tgt_table}, table={table_name}, tgt_schema={tgt_schema}, tgt_table={tgt_table}")

    incremental_Start_Value = '1900-01-01'
    incremental_End_Value = FILEDATE.strftime(r'%Y-%m-%d')

    # Read control table for last extract time
    runtimeConfig, _msg = readControlTable(LZ_DB, tgt_schema, tgt_table)
    if runtimeConfig:
        print(f"Control table has prior value, setting incremental_Start_Value to {runtimeConfig}")
        incremental_Start_Value = runtimeConfig
    else:
        print(f"Control table returned 0 or None, keeping default: {incremental_Start_Value}")

    # Add incremental filter to query without mutating the original config plus explicit order the data by sys_updated_on for consistent pagination
    incremental_filter = f"sys_updated_on>={incremental_Start_Value}^ORDERBYsys_id"

    headers = {"Content-Type": "application/json", "Accept": "application/json"}
    url = f"{base_url}/api/now/table/{table_name}"
    params = {
        "sysparm_exclude_reference_link": True, # simplifies the output from json with link + value, to just contain a str of the value
    }
    if query:
        params["sysparm_query"] = incremental_filter + '^' + query
    else:
        params["sysparm_query"] = incremental_filter
    if fields:
        params["sysparm_fields"] = fields
    print(f"ServiceNow endpoint: {url}, params: {params}")

    df_final = []
    batch_num = 1
    while url:
        response = requests.get(url, headers=headers, auth=auth, params=params, timeout=60)
        status_code = response.status_code
        response.raise_for_status()

        json_load = response.json()
        result = json_load.get("result", [])
        df_result = [{k: v for k, v in d.items() if v != ''} for d in result if isinstance(d, dict)] # Remove empty string values from records
        df_final.extend(df_result)
        
        if batch_num == 1:
            total_count = int(dict(response.headers)['X-Total-Count'])
            total_batches = total_count // 10_000 + 1
            print(f"Status code: {status_code}. Total records to extract for {tgt_table}: {total_count}")
            params = None
        print(f"Batch {batch_num}/{total_batches} extracted for {tgt_table}, records in this batch: {len(df_result)}")
        batch_num += 1
        url = response.links.get('next', {}).get('url', '')
    print(f"Completed extraction for {tgt_table}, total records extracted: {len(df_final)}")            

    if len(df_final) == 0:
        print(f"No new records since {incremental_Start_Value}")
        return
    
    file_name = f"{tgt_table}-{RUN_TIME}.json"
    db_messages = putSnowflakeDataFrame(
        db=LZ_DB,
        schema=tgt_schema,
        tableName=tgt_table,
        df=df_final,
        fileName=file_name,
        fileDate=FILEDATE,
    )
    if 'FAIL_SIGNAL' in db_messages:
        raise Exception(f"Failed to load data into Snowflake for {tgt_table}: {db_messages}")
    print(f"Successfully loaded {tgt_table} in Snowflake")

    # Update control table for incremental loads
    extraction_End_Time = str(datetime.now()).replace(" ", "_").replace(":", "_").replace(".", "_")
    control_messages = loadControlTable(
        LZ_DB,
        tgt_schema,
        str(FILEDATE),
        incremental_Start_Value,
        incremental_End_Value,
        extraction_Start_Time,
        extraction_End_Time,
        tgt_table,
        str(FILEDATE), # TODO: deprecate this column
        len(df_final),
    )
    if "FAIL_SIGNAL" in control_messages:
        raise Warning(f"Failed to update control table for {tgt_table}: {control_messages}")
    print(f"Successfully updated control table for {tgt_table}")


def main(resource_name=None):
    """
    Main function to orchestrate ServiceNow data extraction.

    Args:
        resource_name (str or None): Name of resource to extract, or None to process all resources
    """
    # Load configuration
    with open(CONN_CONFIG_PATH, "r", encoding="utf-8") as f:
        sn_config = json.load(f)
    resources = sn_config.get("resources", {})
    if not resources:
        raise Exception("No resources found in configuration")

    # Extract connector configuration
    connectors = sn_config.get("connectors", {})
    base_url = connectors.get("base_url")
    user_key = connectors.get("user_key")
    password_key = connectors.get("password_key")
    instance = connectors.get("instance")
    tgt_schema = connectors.get("sf_schema")

    # Get credentials from Key Vault
    username = getAzureSecret(user_key).value
    password = getAzureSecret(password_key).value
    auth = HTTPBasicAuth(username, password)
    print(f"Authenticated with ServiceNow instance: {instance}")

    # Process each resource
    errors = []
    for section_name, section in resources.items():
        # Skip if filtering by resource_name and this isn't it
        if resource_name and section_name != resource_name:
            continue
        print(f"\nProcessing resource: {section_name}")
        try:
            requestServiceNowData(tgt_schema, base_url, auth, section)
        except Exception as e:
            print(f"Error processing resource {section_name}: {str(e)}")
            errors.append((section_name, str(e)))

    # Check for failures
    if len(errors) > 0:
        raise Exception(f"getServiceNowData failed for {len(errors)} tables. Error details: {errors}")
    print("getServiceNowData completed for all resources")


if __name__ == "__main__":
    resource_name=None
    args = sys.argv[1:]
    if len(args) > 0:
        resource_name = args[0].lower()
    main(resource_name)
