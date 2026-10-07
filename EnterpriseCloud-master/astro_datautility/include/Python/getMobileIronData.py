import requests
from include.Python.TELTools import getAzureSecret, putSnowflakeDataFrame
import json
import pandas as pd
import os
from datetime import datetime
from requests.auth import HTTPBasicAuth
import time


# Get the API Key to be used for OAuth
def get_auth_details():
    try:
        connection_details = {}
        username = getAzureSecret("IVANTI-USERNAME").value
        password = getAzureSecret("IVANTI-PASSWORD").value
        api_url = getAzureSecret("IVANTI-API-URL").value
        dm_partition_id = getAzureSecret("IVANTI-MPARTITION-ID").value
        devices_url = (
            f"{api_url}/api/v1/device/partitions?dmPartitionId={dm_partition_id}"
        )
        print("Got the auth details Successfully")
    except ConnectionError as ce:
        print("Error in Connecting to Azure KeyVault, Please Retry")
        print("Connection Error:" + ce)
        raise
    return (username, password, devices_url, api_url)


# Read Config Entries to Build the Iterator Module
def get_total_count():
    username, password, devices_url, api_url = get_auth_details()
    
    try:
        response = requests.get(devices_url, auth=HTTPBasicAuth(username, password))
        if response.status_code == 200:
            data = response.json()
            totalCount = data["result"]["totalCount"]
            print(f"Data Received!, totalCount - {totalCount}")
            return totalCount
        else:
            print(f"Failed to fetch data. Status code: {response.status_code}")
            response.raise_for_status()
    except requests.exceptions.RequestException as e:
        print(f"An error occured: {e}")
        raise

# Data Extraction
def data_extract(
    sf_database_name,
    sf_schema_name,
    sf_table_name,
    totalCount,
    rows_per_page,
    current_date,
    extract_datetimestamp,
):
    username, password, devices_url, api_url = get_auth_details()
    file_name = (
        api_url + "_1_" + datetime.strftime(current_date, "%Y-%m-%dT%H%M%S") + ".json"
    )

    search_results = []

    for start in range(0, totalCount, rows_per_page):
        params = {
            "rows": rows_per_page,
            "start": start,
        }
        print(start, rows_per_page, totalCount)

        
        try:
            response = requests.get(
                devices_url, auth=HTTPBasicAuth(username, password), params=params
            )

            if response.status_code == 200:
                json_data = json.dumps(response.json())
                data = json.loads(json_data)
                search_results.extend(data["result"]["searchResults"])
                print("Data Received!", start + rows_per_page)
            else:
                print(f"Failed to fetch data. Status code: {response.status_code}")
                response.raise_for_status()
                break
        except requests.exceptions.RequestException as e:
            print(f"An error occured: {e}")
            raise

    dfs = pd.json_normalize(search_results)
    json_list = dfs.apply(lambda x: json.loads(x.to_json()), axis=1).to_list()
    record_count = len(json_list)
    print(f"Starting ingestion in {sf_database_name}.{sf_schema_name}.{sf_table_name}")
    return_messages = putSnowflakeDataFrame(
        sf_database_name,
        sf_schema_name,
        sf_table_name,
        json_list,
        file_name,
        extract_datetimestamp,
        record_count,
    )
    if 'FAIL_SIGNAL' in return_messages:
        raise Exception('\n'. join(return_messages))
    print(return_messages)


def main():
    totalCount = get_total_count()
    current_date = datetime.now()

    current_date = datetime.now()
    extract_datetimestamp = current_date

    rows_per_page = 500

    extract_datetimestamp = current_date
    sf_database_name = os.getenv("SNOWFLAKE_LZ")
    sf_schema_name = "TEH_INFOSEC"
    sf_table_name = "MOBILEIRON_DEVICES"
    print("In main function now")

    data_extract(
        sf_database_name,
        sf_schema_name,
        sf_table_name,
        totalCount,
        rows_per_page,
        current_date,
        extract_datetimestamp,
    )


if __name__ == "__main__":
    main()
