import oracledb
import json
import pandas as pd
import sys
import os
from datetime import datetime
from typing import Dict, List, Tuple, Optional, Any
from dataclasses import dataclass
from functools import partial
import numpy as np
import include.Python.TELTools as TT
import re

import warnings
warnings.filterwarnings("ignore")
#globals

RUNTIME_ENV = os.environ.get("RUNTIME_ENV", "windows").lower()
print(f"Runtime environment: {RUNTIME_ENV}")

script_dir = os.path.dirname(__file__)

_config_file = (
    "TelTools_Oracle_Connectors_mini.json"
    if RUNTIME_ENV != "astro"
    else "TelTools_Oracle_Connectors.json"
)

CONN_CONFIG_PATH = os.path.abspath(
    os.path.join(script_dir, "..", "Configuration", _config_file)
)

SPC_CASE_QRY = """select
                        MAC_HIST_REASON_NAME_J,
                        MAC_HIST_REASON_NAME,
                        PROJECT_NO,
                        MODEL_TYPE,
                        SERIAL_NUMBER_ID,
                        NCDR_NUMBER,
                        MACHINE_SERIAL_NUMBER,
                        MACHINE_STATUS,
                        MACHINE_SYSTEM_TYPE,
                        TO_CHAR(TO_TIMESTAMP(MACHINE_EXIT_FACTORY_DATE, 'DD-MON-RR HH.MI.SS.FF AM')) AS MACHINE_EXIT_FACTORY_DATE,
                        TO_CHAR(TO_TIMESTAMP(MACHINE_SYSTEM_ACCEPTANCE_DATE, 'DD-MON-RR HH.MI.SS.FF AM')) AS MACHINE_SYSTEM_ACCEPTANCE_DATE,
                        TO_CHAR(TO_TIMESTAMP(MACHINE_STARTUP_START_DATE, 'DD-MON-RR HH.MI.SS.FF AM')) AS MACHINE_STARTUP_START_DATE,
                        TO_CHAR(TO_TIMESTAMP(MACHINE_WARRANTY_START_DATE, 'DD-MON-RR HH.MI.SS.FF AM')) AS MACHINE_WARRANTY_START_DATE,
                        TO_CHAR(TO_TIMESTAMP(MACHINE_WARRANTY_EXPIRE_DATE, 'DD-MON-RR HH.MI.SS.FF AM')) AS MACHINE_WARRANTY_EXPIRE_DATE,
                        WARRANTY_STATUS_ID,
                        OBJECT_NUMBER,
                        SUPPLIER_CD,
                        DEFECTIVE_PORTION_ID,
                        FRF_FLAG,
                        MAC_HIST_REASON_ID
                    from NOW_OWNER.T_SERIAL_NUMBERS"""

CURRENT_DATE = datetime.now()
RUN_TIME = CURRENT_DATE.strftime("%Y-%m-%d %H:%M:%S.%f")
CURRENT_TIMESTAMP = CURRENT_DATE.strftime("%Y-%m-%d_%H_%M_%S_%f")

DATABASE_NAME=os.getenv('SNOWFLAKE_LZ')

@dataclass
class ConnectionConfig:
    """Configuration for Oracle database connection."""
    server: str
    port: str
    database: str
    username: str
    password_name: str

@dataclass
class DatasetConfig:
    """Configuration for a dataset extraction."""
    table: str
    schema: str
    incremental_field: str
    sf_table_name: str
    sf_schema_name: str

class CredentialError(Exception):
    """Raised when credential retrieval fails."""
    pass

def decode_sketchy_utf8(raw_bytes):
    try:
        s = raw_bytes.encode("utf-8", "ignore")
        return s
    except ValueError:
        return raw_bytes

def output_type_handler(cursor, name, default_type, size, precision, scale):
        if default_type == oracledb.STRING:
            return cursor.var(oracledb.STRING, arraysize=cursor.arraysize, outconverter=decode_sketchy_utf8)

def load_json_config(filepath: str):
    try:
        with open(filepath,'r') as f:
            return json.load(f)
    except FileNotFoundError:
        raise FileNotFoundError(f"Configuration file not found: {filepath}")
    except json.JSONDecodeError as e:
        raise ValueError(f"Invalid JSON in configuration file: {e}")

def extract_server_name(config_filename: str) -> str:
    """Extract server name from configuration filename."""
    match = re.search(r'TelTools_Oracle_(.+)_Extract',config_filename)
    if match:
        return match.group(1)
    raise ValueError(f"Invalid config filename format: {config_filename}")


def get_connection_config(servername:str) -> ConnectionConfig:
    ora_config = load_json_config(CONN_CONFIG_PATH)

    for key, config in ora_config.items():
        if key.lower() == servername.lower():
            return ConnectionConfig(
                server=config['servername'],
                port=config['port'],
                database=config['database'],
                username=config['username'],
                password_name=config['password']
            )

    raise ValueError(f"Connection details not found for server: {servername}")

def get_azure_credentials(connection_config: ConnectionConfig) -> Tuple[str, str]:
    try:
        username = TT.getAzureSecret(connection_config.username).value
        password = TT.getAzureSecret(connection_config.password_name).value
        if not username or not password:
            raise CredentialError("Retrieved empty credentials from Azure Key Vault")
        return username, password
    except Exception as e:
        raise Exception(f"Failed in get_azure_credentials: {str(e)}")


def get_dataset_configs(server_name: str) -> List[DatasetConfig]:
    #config_path = f'F:\\Shares\\Configuration\\TelTools_Oracle_{server_name.title()}_Extract.json'
    config_path = os.path.abspath(os.path.join(script_dir, "..", "Configuration", f"TelTools_Oracle_{server_name}_Extract.json"))
    dataset_config = load_json_config(config_path)

    configs = []
    for key, server_config in dataset_config.items():
        if key.lower() == server_name.lower():
            # Extract all datasets
            for dataset_key, dataset_info in server_config.items():
                if dataset_key.startswith('DataSet'):
                    configs.append(DatasetConfig(
                        table=dataset_info['table'],
                        schema=dataset_info['schema'],
                        incremental_field=dataset_info['Incremental'],
                        sf_table_name=dataset_info['sftablename'],
                        sf_schema_name=server_name.upper()
                    ))

    return configs

def build_extraction_query(dataset: DatasetConfig, server_name: str, database_name: str) -> Tuple[str, datetime]:
    try:
        if dataset.incremental_field != "NULL":
            # last extraction date from control table
            runtime_config, msg = TT.readControlTable(
                database_name,
                dataset.sf_schema_name,
                dataset.table
            )
            print(msg)
            previous_date = datetime.strptime(runtime_config, "%Y-%m-%d %H:%M:%S")

            # Build incremental query
            date_filter = f"to_date('{previous_date}', 'YYYY-MM-DD HH24:MI:SS')"
            if server_name.title() == "Now":
                date_filter += " - 1"

            query = (f"SELECT * FROM {dataset.schema}.{dataset.table} "
                    f"WHERE {dataset.incremental_field} >= {date_filter}")
        else:
            previous_date = datetime.strptime('1900-01-01 00:00:00', "%Y-%m-%d %H:%M:%S")
            query = f"SELECT * FROM {dataset.schema}.{dataset.table}"

        return query, previous_date
    except Exception as e:
        raise Exception(f"Failed in build_extraction_query: {str(e)}")

def handle_special_table_query(table_name: str) -> Optional[str]:
    if table_name.upper() == 'T_SERIAL_NUMBERS': #Read specific qry fors T_SERIAL_NUMBER invalid daterange issue
        return SPC_CASE_QRY
    else:
        return None

def create_oracle_connection(connection_config: ConnectionConfig, username,password,server_name):
    try:
        if server_name.title() == "Wisdom":

            if RUNTIME_ENV != "astro":
                oracledb.init_oracle_client()
            else:
                oracledb.init_oracle_client(lib_dir="/opt/oracle/instantclient")

        dsn = f"{connection_config.server}/{connection_config.database}"
        return oracledb.connect(
            user=username,
            password=password,
            dsn=dsn,
            retry_count=5,
            retry_delay=60
        )
    except Exception as e:
        raise ConnectionError(f"Unexpected error creating Oracle connection: {e}")

def get_chunk_size(server_name: str) -> int:
    return 70000 if server_name.title() == "Wisdom" else 200000

def process_data_chunks(query: str, connection: oracledb.Connection, dataset: DatasetConfig,
                       chunk_size: int, database_name: str, current_date: datetime) -> int:

    record_count = 0
    file_count = 1
    try:
        for chunk in pd.read_sql(query, con=connection, chunksize=chunk_size):
            json_data = json.loads(chunk.to_json(orient='records'))

            file_name = f"{dataset.table}_{file_count}_{current_date.strftime('%Y-%m-%dT%H%M%S')}.json"

            return_messages = TT.putSnowflakeDataFrame(
                database_name,
                dataset.sf_schema_name,
                dataset.sf_table_name,
                json_data,
                file_name,
                current_date
            )

            if "FAIL_SIGNAL" in return_messages:
                # raise Exception(f"Failed in putSnowflakeDataFrame: {dataset.sf_schema_name}: {str(return_messages)}")
                    return {"success": False,
                            "message": f"Failed in putSnowflakeDataFrame: {dataset.sf_table_name}: {str(return_messages)}",
                            "data": 0}

            file_count += 1
            record_count += len(chunk)

        return  {"success": True,
                "message": return_messages,
                "data": record_count}
    except Exception as e:
        if(str(e))=="year -9999 is out of range":
            return {"success": True,
                "message": f"Failed while read_sql {str(e)}",
                "data": 0}
        return {"success": False,
                "message": f"Failed while read_sql {str(e)}",
                "data": 0}
    finally:
        if connection:
            try:
                connection.close()
            except Exception as close_err:
                print(f"Error closing Oracle connection: {close_err}")


def main(ConfigFileName,TableName):

    server_name = extract_server_name(ConfigFileName)
    connection_config = get_connection_config(server_name)
    username,pwd = get_azure_credentials(connection_config)
    dataset_configs = get_dataset_configs(server_name)

    target_dataset = next(
            (config for config in dataset_configs if config.table == TableName),
            None
        )

    if not target_dataset:
        raise ValueError(f"Table '{TableName}' not found in dataset configurations")

    query, incremental_start = build_extraction_query(target_dataset, server_name, DATABASE_NAME)

    special_query = handle_special_table_query(target_dataset.table)
    if special_query:
        query = special_query
        print(f"Using special query for {target_dataset.table}")

    print(f"Incremental Date: {incremental_start}")
    print(f"Extract Query: {query}")

    conn = create_oracle_connection(connection_config, username, pwd, server_name)

    # Set output type handler for special tables
    if target_dataset.table.upper() == 'T_SERIAL_NUMBERS':
        conn.outputtypehandler = output_type_handler

    chunk_size = get_chunk_size(server_name)
    extract_start_time = str(datetime.now())
    result = process_data_chunks(query,conn,target_dataset,chunk_size,DATABASE_NAME,CURRENT_DATE)
    extract_end_time = str(datetime.now())
    print(result)
    if not result['success']:
        raise Exception(f"Failed during process_data_chunks {result['message']}")

    Incremental_End_Value=datetime.strftime(CURRENT_DATE,"%Y-%m-%d %H:%M:%S")
    load_control_table_status = TT.load_control_table(
                                    CURRENT_TIMESTAMP=RUN_TIME,
                                    Incremental_Start_Value=str(incremental_start),
                                    Incremental_End_Value=Incremental_End_Value,
                                    Extraction_Start_Time=extract_start_time,
                                    Extraction_End_Time=extract_end_time,
                                    table_name=target_dataset.table,
                                    MAX_FILE_DATE=Incremental_End_Value,
                                    rows_loaded=result['data'],
                                    schema=target_dataset.sf_schema_name,
                                    db=DATABASE_NAME
                                )
    if load_control_table_status['status'] == False:
        raise Exception(f"Failed to update ControlTable: {load_control_table_status['message']}")


if __name__ == "__main__":
    args = sys.argv[1:]
    ConfigFileName:str = args[0]
    TableName:str = args[1]
    print("Extracting Data For: ConfigFileName: " + ConfigFileName + ", TableName: " + TableName)
    # set vars, call main
    main(ConfigFileName,TableName)
