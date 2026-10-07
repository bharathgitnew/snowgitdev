import os
import json
import logging
from pendulum import datetime
from airflow.decorators import dag, task
from airflow.operators.python import PythonOperator
from include.Python.getCopyFile import main as PythonCopyFile
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from include.Python.dbt_run_operator_new_platform import create_dbt_task, create_dbt_task_test

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']
logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    execution_schedule="00 7,12 * * *"
    retry_value=0
else:
    execution_schedule=None
    retry_value=0
@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=execution_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["tea_intel_sms"],
)
def DRIVER_TEA_INTEL_SMS(dbt_folder, domainGuid):

    # TEA_INTEL_SMS_DBT = TriggerDagRunOperator(
    #     task_id='TEA_INTEL_SMS_DBT',
    #     trigger_dag_id='DBT_EXECUTION_NEW_PLATFORM',
    #     conf={"model_name": dbt_folder},
    #     wait_for_completion=True
    #     )

    # TEA_INTEL_SMS_TESTS = TriggerDagRunOperator(
    #     task_id='TEA_INTEL_SMS_TESTS',
    #     trigger_dag_id='DBT_TEST_NEW_PLATFORM',
    #     conf={"model_name": dbt_folder},
    #     wait_for_completion=True
    #     )

    TEA_INTEL_SMS_FILE_1 = PythonOperator(
        task_id="TEA_INTEL_SMS_FILE_1",
        python_callable=PythonCopyFile,
        op_kwargs={
            "config_file": "/usr/local/airflow/include/Configuration/TelTools_CopyFile_File.json",
            "section":"FILE-INTEL_MSBI_FULL_ITEM_BOM"
        },
    )

    TEA_INTEL_SMS_FILE_2 = PythonOperator(
        task_id="TEA_INTEL_SMS_FILE_2",
        python_callable=PythonCopyFile,
        op_kwargs={
            "config_file": "/usr/local/airflow/include/Configuration/TelTools_CopyFile_File.json",
            "section":"INTEL_VFBOM"
        },
    )

    TEA_INTEL_SMS_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEA_INTEL_SMS_DBT"
        }        
    )

    TEA_INTEL_SMS_TESTS = create_dbt_task_test(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEA_INTEL_SMS_TESTS"
        }          
    )

    TEA_INTEL_SMS_ATLAN_UPLOAD = TriggerDagRunOperator(
        task_id='TEA_INTEL_SMS_ATLAN_UPLOAD',
        trigger_dag_id='SYSTEM_UPDATE_ATLAN',
        conf={"domainGuid": domainGuid},
        wait_for_completion=True
    )

    [TEA_INTEL_SMS_FILE_1, TEA_INTEL_SMS_FILE_2] >> TEA_INTEL_SMS_DBT >> TEA_INTEL_SMS_TESTS >> TEA_INTEL_SMS_ATLAN_UPLOAD

DRIVER_TEA_INTEL_SMS(dbt_folder="tea_intel_sms",domainGuid="2efcdcf7-d5c2-4b6b-86c0-4c6dc5444332")