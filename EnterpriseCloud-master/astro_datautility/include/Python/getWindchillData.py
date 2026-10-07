#Import necessary libraries
import requests
import json
import pandas as pd
import include.Python.TELTools as TT
import os
from datetime import datetime
import sys
from requests.auth import HTTPBasicAuth
import html_to_json
import re

RUN_TIME=datetime.now().strftime("%Y-%m-%d_%H_%M_%S_%f")


def get_keyvault_data():
    try:
        client_username = TT.getAzureSecret('WINDCHILL-USERNAME').value
        client_password = TT.getAzureSecret('WINDCHILL-PASSWORD').value
        tenant_url = TT.getAzureSecret('WINDCHILL-URL').value
        msg="Success"
        return client_username,client_password,tenant_url,msg,0
    except Exception as e:
        msg = "Failed to fetch Client Secret from KeyVault"
        return 0,0,0,msg,1


def get_config_details():
    try:
        with open("/usr/local/airflow/include/Configuration/TelTools_Windchill.json", "r") as f:
            config = json.load(f)
            datasets = config.get('WINDCHILL', {})
            return datasets,0
    except Exception as e:
        msg = "Failed to open config file"
        return f'{msg}, error: {e}',1


def get_windchill_data(view_name):
    START_CURRENT_TIMESTAMP = datetime.now()
    START_CURRENT_TIMESTAMP_STR = datetime.now().strftime("%Y-%m-%d_%H_%M_%S_%f")
    database_name=os.getenv('SNOWFLAKE_LZ')
    sf_schema_name='WINDCHILL'
    sf_table_name=view_name
    username,password,url,msg,status = get_keyvault_data()

    if status != 0:
        print(msg)
        return 1

    try:
        response = requests.get(url, auth=HTTPBasicAuth(username, password))
        if response.status_code != 200:
            print(f"Authentication failed. Status code: {response.status_code}")
            print(f"Response content: {response.text}")
            return 1
        print("Authentication successful! Data received.")
    except requests.exceptions.RequestException as e:
        print(f"HTTP request error: {e}")
        return 1

    html_data = response.text
    body_match = re.search(r'<body[^>]*>(.*?)</body>', html_data, re.DOTALL | re.IGNORECASE)

    if not body_match:
        print("No <body> tag found in the HTML content.")
        return 1

    body_content = body_match.group(1)
    tables = re.findall(r'<table[^>]*>.*?</table>', body_content, re.DOTALL | re.IGNORECASE)

    if not tables or len(tables) != 2:
        print("HTML content structure has changed, possibility of error so not proceeding further, check the html content")
        return 1

    first_table = tables[1]

    try:
        jsondata = html_to_json.convert_tables(first_table)[0]
    except Exception as e:
        print(f"Error converting HTML table to JSON: {e}")
        return 1

    df = pd.DataFrame(data=jsondata)
    df = df.applymap(lambda x: x.strip() if isinstance(x, str) else x)
    record_count = len(df)
    file_name = f"{sf_table_name}{START_CURRENT_TIMESTAMP_STR}.json"

    try:
        TT.putSnowflakeDataFrame(database_name, sf_schema_name, sf_table_name, df, file_name, START_CURRENT_TIMESTAMP)
    except Exception as e:
        print(f"Error loading data into Snowflake: {e}")
        return 1

    print("Data successfully loaded into Snowflake.")

    END_CURRENT_TIMESTAMP_STR = datetime.now().strftime("%Y-%m-%d_%H_%M_%S_%f")
    control_data = {
        'db': database_name,
        'schema': sf_schema_name,
        'RunTime': RUN_TIME,
        'Incremental_Start_Value': '1900-01-01',
        'Incremental_End_Value': '1900-01-01',
        'Extraction_Start_Time': START_CURRENT_TIMESTAMP_STR,
        'Extraction_End_Time': END_CURRENT_TIMESTAMP_STR,
        'File_Name': sf_table_name,
        'MAX_FILE_DATE': '1900-01-01',
        'ROW_COUNT': record_count
    }

    try:
        TT.loadControlTable(
            database_name, sf_schema_name, RUN_TIME,
            control_data['Incremental_Start_Value'], control_data['Incremental_End_Value'],
            START_CURRENT_TIMESTAMP_STR, END_CURRENT_TIMESTAMP_STR,
            sf_table_name, control_data['MAX_FILE_DATE'], record_count
        )
    except Exception as e:
        print(f"Error updating control table: {e}")
        print(f"Control data: {control_data}")
        return 1
    print("Data extraction and control table update complete.")
    return 0

def get_data(view_name):
    datasets,status=get_config_details()
    fail_tbls = []
    if status == 0:
        if view_name.upper()=="ALL":
            for i in datasets:
                res = get_windchill_data(datasets[i].get('snowflake_table'))
                if res != 0:
                    fail_tbls.append(view_name)

        else:
            for i in datasets:
                if(view_name.upper()==datasets[i].get('snowflake_table')):
                    res = get_windchill_data(datasets[i].get('snowflake_table'))
                    if res != 0:
                        fail_tbls.append(view_name)
    if fail_tbls:
        fail_tbls_str = ','.join(fail_tbls)
        raise RuntimeError(f'ingestion failed for {fail_tbls_str}')

    else:
        print(datasets)


def main(view_name):
    get_data(view_name)

if __name__ == "__main__":
    args = sys.argv[1:]
    view_name:str = args[0]
    main(view_name)