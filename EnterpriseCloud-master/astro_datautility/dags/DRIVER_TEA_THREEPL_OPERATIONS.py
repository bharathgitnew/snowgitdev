import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.operators.python import get_current_context
from include.Python.getCopyFile import main as copy

import include.Python.TelTools_SQLServer as tts

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

# if ASTRO_DEPLOYMENT_NAME=='PROD':
#     execution_schedule="00 06,09,15 * * *"
#     retry_value=3
# else:
execution_schedule=None
retry_value=0

def extract_tea_threepl_operations_dataset_names():
    with open('/usr/local/airflow/include/Configuration/TelTools_SQLServer_ThreePL_Extract.json') as f:
        data=json.load(f)
    return [dataset["table"] for dataset in data["ThreePL"].values()]

def extract_table_names():
    with open('/usr/local/airflow/include/Configuration/TelTools_CopyFile_ThreePL.json') as f:
        data=json.load(f)
    return [dataset["table"] for dataset in data["CopyFile"].values()]

@dag(
    start_date=datetime(2025, 9, 2, tz="America/Chicago"),
    schedule=execution_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["threepl"],
)
def DRIVER_TEA_THREEPL_OPERATIONS(dbt_folder,domainGuid):

    THREEPL_DBT = TriggerDagRunOperator(
        task_id='THREEPL_DBT',
        trigger_dag_id='DBT_EXECUTION',
        conf={"model_name": "tag:threepl common.de_threepl --exclude pub.*"},
        wait_for_completion=True
        )

    TEA_THREEPL_OPERATIONS_DBT = TriggerDagRunOperator(
        task_id='TEA_THREEPL_OPERATIONS_DBT',
        trigger_dag_id='DBT_EXECUTION_NEW_PLATFORM',
        conf={"model_name": dbt_folder},
        wait_for_completion=True
        )

    TEA_THREEPL_OPERATIONS_DBT_TESTS = TriggerDagRunOperator(
        task_id='TEA_THREEPL_OPERATIONS_DBT_TESTS',
        trigger_dag_id='DBT_TEST_NEW_PLATFORM',
        conf={"model_name": dbt_folder},
        wait_for_completion=True
        )

    TEA_THREEPL_OPERATIONS_ATLAN_UPLOAD = TriggerDagRunOperator(
        task_id='TEA_THREEPL_OPERATIONS_ATLAN_UPLOAD',
        trigger_dag_id='SYSTEM_UPDATE_ATLAN',
        conf={"domainGuid": domainGuid},
        wait_for_completion=True
    )

    @task(
        map_index_template="{{ TEA_THREEPL_OPERATIONS_CUSTOM_MAP_INDEX }}",
        max_active_tis_per_dag=2
    )
    def EXTRACT_TEA_THREEPL_OPERATIONS(file_path, table_name):
        context = get_current_context()
        context["TEA_THREEPL_OPERATIONS_CUSTOM_MAP_INDEX"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_TEA_THREEPL_OPERATIONS")
        tts.main(file_path, table_name)
        logger.info("Completed EXTRACT_TEA_THREEPL_OPERATIONS")

    @task(
        map_index_template="{{ COPYFILE_MAP_INDEX }}",
        max_active_tis_per_dag=1
    )

    def EXTRACT_COPYFILE(file_path, table_name):
        context = get_current_context()
        context["COPYFILE_MAP_INDEX"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_COPYFILE")
        copy(file_path, table_name)
        logger.info("Completed EXTRACT_COPYFILE")

    EXTRACT_FILES = EXTRACT_COPYFILE.partial(file_path='/usr/local/airflow/include/Configuration/TelTools_CopyFile_ThreePL.json').expand(table_name=extract_table_names())
    
    EXTRACT_TABLES_TEA_THREEPL_OPERATIONS = EXTRACT_TEA_THREEPL_OPERATIONS.partial(file_path='/usr/local/airflow/include/Configuration/TelTools_SQLServer_ThreePL_Extract.json').expand(table_name=extract_tea_threepl_operations_dataset_names())

    [EXTRACT_TABLES_TEA_THREEPL_OPERATIONS,EXTRACT_FILES] >> THREEPL_DBT >> TEA_THREEPL_OPERATIONS_DBT >> TEA_THREEPL_OPERATIONS_DBT_TESTS >> TEA_THREEPL_OPERATIONS_ATLAN_UPLOAD

DRIVER_TEA_THREEPL_OPERATIONS(dbt_folder="tea_threepl_operations",domainGuid="6ac04fc1-345d-4df4-a294-b18097659155")