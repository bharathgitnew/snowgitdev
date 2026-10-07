import pyodbc
import json
import pandas as pd
import sys
import os
import logging
from datetime import datetime
from typing import Dict, List, Optional, Tuple, Any
from dataclasses import dataclass
from pathlib import Path
from datetime import datetime,timedelta,timezone
import struct

import include.Python.TELTools as TT
import numpy as np
import re

#globals
RUNTIME_ENV = os.environ.get("RUNTIME_ENV", "windows").lower()
print(f"Runtime environment: {RUNTIME_ENV}")

script_dir = os.path.dirname(__file__)

_config_file = (
    "TelTools_SQLServer_Connectors_mini.json"
    if RUNTIME_ENV != "astro"
    else "TelTools_SQLServer_Connectors.json"
)

CONN_CONFIG_PATH = os.path.abspath(
    os.path.join(script_dir, "..", "Configuration", _config_file)
)

CURRENT_DATE = datetime.now()
RUN_TIME = CURRENT_DATE.strftime("%Y-%m-%d %H:%M:%S.%f")
CURRENT_TIMESTAMP = CURRENT_DATE.strftime("%Y-%m-%d_%H_%M_%S_%f")

DATABASE_NAME=os.getenv('SNOWFLAKE_LZ')
CHUNK_SIZE=200000 #todo : Search the Optimal Row Count for SQL Server.

@dataclass
class ConnectionConfig:
    server: str
    database: str
    username: Optional[str] = None
    password: Optional[str] = None
    trusted_connection: bool = False

@dataclass
class DatasetConfig:
    table: str
    schema: str
    incremental_field: str
    sf_table_name: str
    filter_condition: str

def handle_datetimeoffset(value):
    year, month, day, hour, minute, second, fraction_ns, tz_minutes = struct.unpack('<hhhhhhIh', value[:18])
    microsecond = fraction_ns // 1000
    dt = datetime(year, month, day, hour, minute, second, microsecond,
                tzinfo=timezone(timedelta(minutes=tz_minutes)))
    return dt.isoformat()

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
    match = re.search(r'TelTools_SQLServer_(.+)_Extract',config_filename)
    if match:
        return match.group(1)
    raise ValueError(f"Invalid config filename format: {config_filename}")

def get_connection_config(servername:str) -> ConnectionConfig:
    sql_config = load_json_config(CONN_CONFIG_PATH)
    for key, config in sql_config.items():
        if key.lower() == servername.lower():
            return ConnectionConfig(
                        server=config["servername"],
                        database=config["database"],
                        username=config.get("username", None),
                        password=config.get("password", None)
                    )

    raise ValueError(f"Connection details not found for server: {servername}")

def get_dataset_configs(server_name: str) -> List[DatasetConfig]:
    #config_path = f'F:\\Shares\\Configuration\\TelTools_Oracle_{server_name.title()}_Extract.json'
    config_path = os.path.abspath(os.path.join(script_dir, "..", "Configuration", f"TelTools_SQLServer_{server_name}_Extract.json"))
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
                        filter_condition=dataset_info.get('filter', '')
                    ))

    return configs

def build_extraction_query(dataset_config: DatasetConfig, server_name: str, database_name: str,sf_schema_name:str) -> Tuple[str, datetime]:

        full_table_name = f"{dataset_config.schema}.{dataset_config.table}"
        previous_date = '1900-01-01 00:00:00'

        # Handle incremental extraction
        if dataset_config.incremental_field != "NULL":
            try:
                runtime_config, _ = TT.readControlTable(
                    database_name, sf_schema_name, dataset_config.table
                )
                previous_date = datetime.strptime(runtime_config, "%Y-%m-%d %H:%M:%S")
            except Exception as e:
                print(f"Failed to read control table: {e}. Using default date.")
                previous_date = datetime.strptime('1900-01-01 00:00:00', "%Y-%m-%d %H:%M:%S")

        base_query = f"SELECT * FROM {full_table_name}"
        where_conditions = []

        if dataset_config.incremental_field != "NULL":
            if server_name == 'CRMHELPDESK':
                incremental_condition = f"{dataset_config.incremental_field} >= DATEADD(HOUR,-4,convert(DATETIME,'{previous_date}'))"
            elif server_name == 'TELCUSTOMER' or server_name == 'TELCUSTOMER-MINI':
                incremental_condition = f"{dataset_config.incremental_field} >= convert(DATETIME,'{previous_date}')"
            else:
                incremental_condition = f"cast({dataset_config.incremental_field} AT TIME ZONE 'UTC' AT TIME ZONE 'Central Standard Time' as datetime) >= convert(DATETIME,'{previous_date}')"

            where_conditions.append(incremental_condition)

        if dataset_config.filter_condition:
            where_conditions.append(dataset_config.filter_condition)

        if where_conditions:
            query = f"{base_query} WHERE {' AND '.join(where_conditions)}"
        else:
            query = base_query

        return query, str(previous_date)

def create_database_connection(connection_config: ConnectionConfig,
                                 username: Optional[str], password: Optional[str]) -> pyodbc.Connection:
        """Create database connection with proper error handling."""
        connection_params = {
            "Driver": "{ODBC Driver 17 for SQL Server}",
            "Server": connection_config.server,
            "Database": connection_config.database,
            "retry_count": 5,
            "retry_delay": 60,
            "Trusted_Connection": "yes" if connection_config.trusted_connection else "no",
            "TrustServerCertificate":"yes",
            "Encrypt":"no"
        }

        if not connection_config.trusted_connection:
            connection_params.update({
                "user": username,
                "password": password
            })
        try:
            return pyodbc.connect(**connection_params)
        except Exception as e:
            raise Exception(f"Failed to connect to database: {str(e)}")


def process_data_chunks(query: str, connection: pyodbc.Connection, dataset: DatasetConfig,
                       chunk_size: int, database_name: str, current_date: datetime,sf_schema_name: str) -> int:

    record_count = 0
    file_count = 1
    process_error = False
    try:
        for chunk in pd.read_sql(query, con=connection, chunksize=chunk_size):
            try:
                json_data=json.loads(chunk.to_json(orient='records'))
            except Exception as e:
                process_error = True
            if process_error:
                for col, datatype in chunk.dtypes.items():
                    if datatype == 'object':
                        try:
                            chunk[col] = chunk[col].apply(lambda x : x.decode('ISO-8859-1') if x!=None else x)
                        except Exception as e:
                            pass
                json_data=json.loads(chunk.to_json(orient='records'))

            file_name = f"{dataset.table}_{file_count}_{current_date.strftime('%Y-%m-%dT%H%M%S')}.json"

            return_messages = TT.putSnowflakeDataFrame(
                database_name,
                sf_schema_name,
                dataset.sf_table_name.upper(),
                json_data,
                file_name,
                current_date
            )

            if "FAIL_SIGNAL" in return_messages:
                # raise Exception(f"Failed in putSnowflakeDataFrame: {dataset.sf_schema_name}: {str(return_messages)}")
                    return {"success": False,
                            "message": f"Failed in putSnowflakeDataFrame: {sf_schema_name}: {str(return_messages)}",
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
                print(f"Error closing SQL connection: {close_err}")

def main(ConfigFileName,TableName):

    server_name = extract_server_name(ConfigFileName)
    print(f'Process starts for server::{server_name}')
    connection_config = get_connection_config(server_name)

    if connection_config.username is None and connection_config.password is None:
        connection_config.trusted_connection = True
    else:
        try:
            username=(TT.getAzureSecret(connection_config.username).value)
        except Exception as e:
            username = connection_config.username

        pwd=(TT.getAzureSecret(connection_config.password).value)
        connection_config.trusted_connection = False

    sf_schema_name=server_name.upper().split('-')[0]

    dataset_configs = get_dataset_configs(server_name)

    target_dataset = next(
            (config for config in dataset_configs if config.table == TableName),
            None
        )

    print(f'Process starts for object: {target_dataset.table}')

    if not target_dataset:
        raise ValueError(f"Table '{TableName}' not found in dataset configurations")

    query, incremental_start = build_extraction_query(target_dataset, server_name, DATABASE_NAME,sf_schema_name)

    print(f"Incremental Date: {incremental_start}")
    print(f"Extract Query: {query}")


    conn = create_database_connection(connection_config, username, pwd)
    if 'TelTools_SQLServer_TELCUSTOMER-DIVERSESYSTEMS_Extract' in ConfigFileName:
        conn.add_output_converter(-155, handle_datetimeoffset)

    if 'TelTools_SQLServer_IPR-VIEWS_Extract' in ConfigFileName:
        conn.add_output_converter(-155, handle_datetimeoffset)

    extract_start_time = str(datetime.now())
    result = process_data_chunks(query,conn,target_dataset,CHUNK_SIZE,DATABASE_NAME,CURRENT_DATE,sf_schema_name)
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
                                    schema=sf_schema_name,
                                    db=DATABASE_NAME
                                )
    if load_control_table_status['status'] == False:
        raise Exception(f"Failed to update ControlTable: {load_control_table_status['message']}")

    print(f'Processing Ends for: {target_dataset.table}')


if __name__ == "__main__":
    args = sys.argv[1:]
    ConfigFileName:str = args[0]
    TableName:str = args[1]
    print("Extracting Data For: ConfigFileName: " + ConfigFileName + ", TableName: " + TableName)
    # set vars, call main
    main(ConfigFileName,TableName)
