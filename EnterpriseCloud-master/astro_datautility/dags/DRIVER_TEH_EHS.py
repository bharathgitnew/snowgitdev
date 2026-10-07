import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from include.Python.dbt_run_operator_new_platform import create_dbt_task, create_dbt_task_test

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']
logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    execution_schedule="0 3-23/4 * * *"
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
    tags=["teh_ehs"],
)

def DRIVER_TEH_EHS(dbt_folder,domainGuid):

    TEH_EHS_EXTRACT = TriggerDagRunOperator(
        task_id='TEH_EHS_EXTRACT',
        trigger_dag_id='SYSTEM_GET_BOX_FILES',
        conf={"config_path":"/usr/local/airflow/include/Configuration/TelTools_getBoxFile_FILE.json"},
        wait_for_completion=True
        )
    
    TEH_EHS_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEH_EHS_DBT"
        }        
    )

    TEH_EHS_TESTS = create_dbt_task_test(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEH_EHS_TESTS"
        }          
    )

    TEH_EHS_ATLAN_UPLOAD = TriggerDagRunOperator(
        task_id='TEH_EHS_ATLAN_UPLOAD',
        trigger_dag_id='SYSTEM_UPDATE_ATLAN',
        conf={"domainGuid": domainGuid},
        wait_for_completion=True
    )

    TEH_EHS_EXTRACT >> TEH_EHS_DBT >> TEH_EHS_TESTS >> TEH_EHS_ATLAN_UPLOAD
    
DRIVER_TEH_EHS(dbt_folder="teh_ehs",domainGuid="8a03710a-1d13-4863-81d1-019ed363ee20")

