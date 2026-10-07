import os
import base64
import requests
import csv
import include.Python.TELTools as TT
from azure.storage.blob import BlobClient, ContainerClient, __version__
from datetime import datetime,date
import io
import json
import pandas as pd
import pytz


# globals
batch_datetimestamp = datetime.now()
CURRENT_TIMESTAMP = str(batch_datetimestamp).replace(" ","_").replace(":","_").replace(".","_")
PAT = TT.getAzureSecret('TMEA-AZURE-DEVOPS').value
# work_item_config_path= '/usr/local/airflow/include/Configuration/TelTools_AzureDevops_WorkItemDetails.json'
# work_item_config_path ='Configuration\TelTools_AzureDevops_WorkItemDetails.json'
LZ_DB = os.environ["SNOWFLAKE_LZ"]
database_name=os.getenv('SNOWFLAKE_LZ')

RUNTIME_ENV = os.environ.get("RUNTIME_ENV", "windows").lower()
print(f"Runtime environment: {RUNTIME_ENV}")

script_dir = os.path.dirname(__file__)

_config_file = (
    "TelTools_AzureDevops_WorkItemDetails_mini.json"
    if RUNTIME_ENV != "astro"
    else "TelTools_AzureDevops_WorkItemDetails.json"
)

work_item_config_path = os.path.abspath(
    os.path.join(script_dir, "..", "Configuration", _config_file)
)

def getWorkItemConfig():
    with open(work_item_config_path,'r') as f:
        config_json = json.load(f,strict=False)
        site_config_json = config_json.get('WorkItemDetails').get('SiteConfig')
        org_url = site_config_json.get('org_url')
        work_item_site = site_config_json.get('work_item_site')
        # get snowflake connection variables
        sf_config_json = config_json.get('WorkItemDetails').get('SnowflakeConn')
        sf_schema_name = sf_config_json.get('SNOWFLAKE_SCHEMA_NAME')
        sf_table_name = sf_config_json.get('SNOWFLAKE_TABLE_NAME')

    return org_url, work_item_site, sf_schema_name, sf_table_name

def readControlTable(sf_schema,table_name):
    print("inside run time config")
    messages = []
    db = LZ_DB
    schema = sf_schema
    conn, messages = TT.getSnowFlakeConn(db, schema, messages)
    if conn != "no connection":
        try:
            cur = conn.cursor()
            query="select INCREMENTAL_END_VALUE from "+db+"."+schema+".CONTROLTABLE WHERE TABLE_NAME='"+table_name+"' order by RUN_TIME desc limit 1"
            cur.execute(query)
            results = cur.fetchall()
            data = [i[0] for i in results]
            if data == []:
                last_run_time = None
            else:
                last_run_time = data[0]
            messages.append(
                f"readControlTable(): Read from snowflake completed for {db}, {schema}, CONTROLTABLE- {data}"
            )
            conn.close()
            return last_run_time, messages
        except Exception as e:
            print(f"Error reading from snowflake: ,{table_name}")
            print(e)
            messages.append(f"FAIL_SIGNAL")
            messages.append(
                f"Read Data: Read from snowflake failed for {db}, {schema}, {table_name}: {e}"
            )
            conn.close()
            return 0, messages
    else:
        print("connection not done")

def load_control_table(
    CURRENT_TIMESTAMP,
    Incremental_Start_Value,
    Incremental_End_Value,
    Extraction_Start_Time,
    Extraction_End_Time,
    table_name,
    MAX_FILE_DATE,
    rows_loaded,
    schema,
    db,
):
    """Load data into the control table in Snowflake and return status messages."""
    try:
        messages = TT.loadControlTable(
            db,
            schema,
            CURRENT_TIMESTAMP,
            Incremental_Start_Value,
            Incremental_End_Value,
            Extraction_Start_Time,
            Extraction_End_Time,
            table_name,
            MAX_FILE_DATE,
            rows_loaded,
        )

        if "FAIL_SIGNAL" in messages:
            return {"status": False, "message": messages}
        else:
            return {"status": True, "message": messages}
    except Exception as e:
        error_message = f"Error in load_control_table {table_name}: {e}"
        print(error_message)
        return {"status": False, "message": error_message}

#Method to extract data from Azure Devops:
def get_Data(org_url, work_item_site, last_run_date):
    headers = {}
    extract_datetimestamp = datetime.now()
    if PAT is not None:
        headers['Authorization'] = 'Basic ' + base64.b64encode(bytes(':' + PAT, 'utf-8')).decode('ascii')
        headers['Content-Type'] = 'application/json'
        headers['Accept'] = 'application/json'
    # Get all the pull requests in the project
    if last_run_date is None:
        last_run_date = date.today()
        payload = json.dumps({"query": f"Select * From WorkItems WHERE [System.ChangedDate] <= '{last_run_date} GMT'"})
    else:
        payload = json.dumps({"query": f"Select * From WorkItems WHERE [System.ChangedDate] >= '{last_run_date} GMT'"})
    url=org_url+"/"+work_item_site
    response = requests.request("POST",url,headers=headers,data=payload, verify= False)
    detailed_items = json.loads(response.text)
    data = []
    # print("Detailed Items1 is : ", detailed_items)
    for i in detailed_items['workItems']:
        workitemid = i['id']
        url1 = f"{org_url}/_apis/wit/workitems/{workitemid}?api-version=7.1-preview.3"
        response1 = requests.get(url1, headers=headers, verify= False)
        data.append(response1.json())
    return(extract_datetimestamp,data,len(data))

#Method to load data into Snowflake:
def load_Data(org_url, work_item_site,sf_schema_name, sf_table_name,last_run_date):
    (extract_datetimestamp,dataset,record_count)=get_Data(org_url, work_item_site,last_run_date)
    print("Records extracted from azure devops", record_count)
    file_name='Work_Items_'+datetime.strftime(extract_datetimestamp,"%Y-%m-%dT%H%M%S")+'.json'
    try:
        return_messages = TT.putSnowflakeDataFrame(database_name,sf_schema_name,sf_table_name,dataset,file_name,extract_datetimestamp,record_count)
        print(return_messages)
    except Exception as e:
        error_message = f"Error in ingesting data to Work_item_details : {e}"
        print(error_message)
        return None,datetime.strftime(extract_datetimestamp,"%Y-%m-%dT%H%M%S")
    return record_count,datetime.strftime(extract_datetimestamp,"%Y-%m-%dT%H%M%S")

#Main Method
def main():
    try :
        org_url, work_item_site,sf_schema_name, sf_table_name = getWorkItemConfig()
        print(f'''Work Item Config values:
            org_url: {org_url}
            work_item_site: {work_item_site}
            sf_schema_name: {sf_schema_name}
            sf_table_name: {sf_table_name}
        ''')
        last_run_date, message = readControlTable(sf_schema_name,'WORK_ITEM_DETAILS')
        if last_run_date ==0:
            raise Exception(f'Unable to read from Control Table')
        elif last_run_date is not None:
            last_run_date= datetime.strptime(last_run_date,"%Y-%m-%dT%H%M%S").date()
        elif last_run_date is None:
            print("Since Last run date is None: Reading bulk data from source")
        print("Read Controltable result-message: ",message)
        print("Last Run Date is: ", last_run_date)
        total_row_count,run_name=load_Data(org_url, work_item_site,sf_schema_name, sf_table_name,last_run_date)
        print("Updating Metadata")
        batch_end_datetimestamp = datetime.strftime(datetime.now(),"%Y-%m-%dT%H%M%S")
        control_table_result = load_control_table(
            CURRENT_TIMESTAMP,
            last_run_date,
            run_name,
            datetime.strftime(batch_datetimestamp,"%Y-%m-%dT%H%M%S"),
            batch_end_datetimestamp,
            'WORK_ITEM_DETAILS',
            'NA',
            total_row_count,
            sf_schema_name,
            LZ_DB
        )
        print("Control table result: ",control_table_result)
    except Exception as e:
        raise Exception(f"Error in main function :{str(e)}")

if __name__ == "__main__":
    main()