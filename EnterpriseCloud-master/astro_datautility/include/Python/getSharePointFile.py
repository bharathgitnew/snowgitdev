import os
import json
import fnmatch
import sys
import requests
import io
import pandas as pd
from datetime import datetime
from include.Python.TELTools import getAzureSecret, putSnowflakeDataFrame, readControlTable, load_control_table
from include.Python.getMSGraphData import getGraphToken, buildGraphURL, requestGraphData

CONFIG_PATH = os.path.join(
    os.path.dirname(__file__),
    "..", "Configuration", "TelTools_SharePointFile.json"
)
CONFIG_PATH = os.path.abspath(CONFIG_PATH)


RUN_TIME = datetime.now()
SF_DB = os.environ["SNOWFLAKE_LZ"]
CURRENT_TIMESTAMP = str(RUN_TIME).replace(" ", "_").replace(":", "_").replace(".", "_")

#MS Graph Connection details
BASE_URL = "https://graph.microsoft.com/v1.0"
TENANT_ID = "8c433003-a081-4dfb-a631-100526250b1a"
CLIENT_ID = "5e456920-adaa-48e1-a8db-241cad08b48b"
CLIENT_SECRET_NAME = "SPO-SECRET"
OAUTH_URL = "https://login.microsoftonline.com"




def download_and_post_files(job, base_url, headers):
    audit_log = []
    incremental_End_Value = '19000101'
    extraction_Start_Time = str(datetime.now()).replace(" ","_").replace(":","_").replace(".","_")
    tgt_schema = job["destination_schema"]
    tgt_table = job["destination_table"]

    graph_endpoint = buildGraphURL(
        base_url, job["resource_type"], job["resource_id"], job.get("subresource"), job.get("extra_path"), job.get("params")
    )
    api_result = requestGraphData(graph_endpoint, headers)
    if not api_result.get("status"):
        return False, f"API error: {api_result.get('message', 'Unknown error')}"

    matched_files = [item for item in api_result["data"] if fnmatch.fnmatch(item["name"], job["file_pattern"])]
    if not matched_files:
        print(f"No files matched pattern '{job['file_pattern']}' for job '{job['job_name']}'")
        return True, "No matched files exist"

    matched_files.sort(key=lambda x: x.get("lastModifiedDateTime")) # Sort files by lastModifiedDateTime in ascending order, start ingesting oldest first to ensure incremental load works correctly
    runtimeConfig, _msg = readControlTable(SF_DB, tgt_schema, tgt_table)
    if runtimeConfig:
        incremental_End_Value = runtimeConfig

    latest_modified = incremental_End_Value
    for item in matched_files:
        name = item["name"]
        section_lastModifiedDateTime = item["lastModifiedDateTime"]
        if section_lastModifiedDateTime <= incremental_End_Value:
            print(f"Skipping file '{name}' because lastModifiedDateTime ({section_lastModifiedDateTime}) <= incremental_End_Value ({incremental_End_Value})")
            continue
        if section_lastModifiedDateTime > latest_modified:
            latest_modified = section_lastModifiedDateTime

        download_link = item.get("@microsoft.graph.downloadUrl")
        if not download_link:
            return False, f"Download link missing for file {name}"

        response = requests.get(download_link, headers=headers)
        if response.status_code != 200:
            return False, f"File download failed for {name}: {response.reason}"

        try:
            if '.xl' in name:
                sheet_no = job.get("sheet_no", 0)
                header_row = 0 if job.get("has_header", True) else None
                excel_data = io.BytesIO(response.content)
                data_load = pd.read_excel(excel_data, sheet_name=sheet_no, header=header_row, dtype=str)
            else:
                data_load = pd.read_csv(io.StringIO(response.content.decode('utf-8')),dtype=str)
            data_load = data_load.dropna(how='all').reset_index(drop=True)
            file_data = json.loads(data_load.to_json(orient='records'))
            file_data = [
                {key.replace("\n", ""): value for key, value in d.items()}
                for d in file_data
            ]
            row_count = len(file_data)
            file_name = name

            messages = putSnowflakeDataFrame(
                SF_DB,
                tgt_schema,
                tgt_table,
                file_data,
                file_name,
                RUN_TIME,
                row_count,
            )
            print(messages)
            if "FAIL_SIGNAL" in messages:
                return False, f"Snowflake load failed for {name}: {messages}"


            load_control_table_status= load_control_table(
                    CURRENT_TIMESTAMP=CURRENT_TIMESTAMP,
                    Incremental_Start_Value=incremental_End_Value,
                    Incremental_End_Value=latest_modified,
                    Extraction_Start_Time=extraction_Start_Time,
                    Extraction_End_Time=str(datetime.now()).replace(" ","_").replace(":","_").replace(".","_"),
                    table_name=tgt_table,
                    MAX_FILE_DATE=CURRENT_TIMESTAMP,
                    rows_loaded=row_count,
                    schema=tgt_schema,
                    db=SF_DB
                )

            if load_control_table_status['status'] == False:
                return False, f"Failed to update ControlTable: {load_control_table_status['message']}"

        except Exception as e:
            return False, f"Error processing file {name}: {str(e)}"

    return True, "Success"

def main(job):
    try:
        with open(CONFIG_PATH, "r") as f:
            config = json.load(f)
        jobs = config["sharepoint_file_jobs"]
    except (FileNotFoundError, json.JSONDecodeError, KeyError) as e:
        raise Exception(f"Failed to load configuration or missing 'sharepoint_file_jobs' key: {e}")

    client_secret = getAzureSecret(CLIENT_SECRET_NAME).value
    token_result = getGraphToken(CLIENT_ID, client_secret, TENANT_ID, OAUTH_URL)

    if not token_result["status"]:
        raise Exception(f"Failed for getGraphToken: {token_result['message']}")
    print("Access Token generated.")
    
    headers = {"Authorization": f'Bearer {token_result["data"]}'}

    failed_jobs = []
    if job == "ALL":
        jobs_to_run = jobs
    else:
        jobs_to_run = [j for j in jobs if j["job_name"] == job]
        if not jobs_to_run:
            raise Exception(f"No job found with job_name: {job}")

    for job_item in jobs_to_run:
        success, message = download_and_post_files(
            job_item, BASE_URL, headers
        )
        if not success:
            failed_jobs.append({"job_name": job_item["job_name"], "reason": message})

    if failed_jobs:
        fail_msgs = "\n".join([f"{j['job_name']}: {j['reason']}" for j in failed_jobs])
        raise Exception(f"Some jobs failed:\n{fail_msgs}")
    else:
        print("All SharePoint file jobs completed successfully.")
if __name__ == "__main__":
    args = sys.argv[1:]
    job_name:str = args[0] # Expecting a job name or "ALL"
    main(job_name)