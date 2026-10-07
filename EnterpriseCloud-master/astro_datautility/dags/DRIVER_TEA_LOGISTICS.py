import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.operators.python import get_current_context
from include.Python.getCopyFile import main as copy
import include.Python.TelTools_SQLServer as tts
from include.Python.dbt_run_operator_new_platform import create_dbt_task, create_dbt_task_test
from include.Python.dbt_run_operator import create_dbt_task as create_dbt_task_old_platform

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    execution_schedule="00 06,09,15 * * *"
    retry_value=0
else:
    execution_schedule=None
    retry_value=0

def extract_tea_logistics_dataset_names():
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
    tags=["logistics"],
)
def DRIVER_TEA_LOGISTICS(dbt_folder,domainGuid):

    # THREEPL_DBT = TriggerDagRunOperator(
    #     task_id='THREEPL_DBT',
    #     trigger_dag_id='DBT_EXECUTION',
    #     conf={"model_name": "tag:threepl common.de_threepl --exclude pub.*"},
    #     wait_for_completion=True
    #     )

    # TEA_LOGISTICS_DBT = TriggerDagRunOperator(
    #     task_id='TEA_LOGISTICS_DBT',
    #     trigger_dag_id='DBT_EXECUTION_NEW_PLATFORM',
    #     conf={"model_name": dbt_folder},
    #     wait_for_completion=True
    #     )

    # TEA_LOGISTICS_DBT_TESTS = TriggerDagRunOperator(
    #     task_id='TEA_LOGISTICS_DBT_TESTS',
    #     trigger_dag_id='DBT_TEST_NEW_PLATFORM',
    #     conf={"model_name": dbt_folder},
    #     wait_for_completion=True
    #     )

    THREEPL_DBT = create_dbt_task_old_platform(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": "tag:threepl common.de_threepl --exclude pub.*",
            "task_id" : "THREEPL_DBT"
        }        
    )

    TEA_LOGISTICS_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEA_LOGISTICS_DBT"
        }        
    )

    TEA_LOGISTICS_DBT_TESTS = create_dbt_task_test(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEA_LOGISTICS_DBT_TESTS"
        }          
    )

    TEA_LOGISTICS_ATLAN_UPLOAD = TriggerDagRunOperator(
        task_id='TEA_LOGISTICS_ATLAN_UPLOAD',
        trigger_dag_id='SYSTEM_UPDATE_ATLAN',
        conf={"domainGuid": domainGuid},
        wait_for_completion=True
    )

    @task(
        map_index_template="{{ TEA_LOGISTICS_CUSTOM_MAP_INDEX }}",
        max_active_tis_per_dag=2
    )
    def EXTRACT_TEA_LOGISTICS(file_path, table_name):
        context = get_current_context()
        context["TEA_LOGISTICS_CUSTOM_MAP_INDEX"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_TEA_LOGISTICS")
        tts.main(file_path, table_name)
        logger.info("Completed EXTRACT_TEA_LOGISTICS")

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
    EXTRACT_TABLES_TEA_LOGISTICS = EXTRACT_TEA_LOGISTICS.partial(file_path='/usr/local/airflow/include/Configuration/TelTools_SQLServer_ThreePL_Extract.json').expand(table_name=extract_tea_logistics_dataset_names())

    [EXTRACT_TABLES_TEA_LOGISTICS,EXTRACT_FILES] >> THREEPL_DBT >> TEA_LOGISTICS_DBT >>TEA_LOGISTICS_DBT_TESTS >> TEA_LOGISTICS_ATLAN_UPLOAD

DRIVER_TEA_LOGISTICS(dbt_folder="tea_logistics",domainGuid="d8961077-e79e-4ba9-8ccc-f561bdb6223c")