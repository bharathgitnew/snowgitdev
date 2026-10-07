import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from include.Python.dbt_run_operator_new_platform import create_dbt_task, create_dbt_task_test

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']
logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    execution_schedule="39 7 * * *"
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
    tags=["tea_planning"],
)
def DRIVER_TEA_PLANNING(dbt_folder, domainGuid):


    TEA_PLANNING_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEA_PLANNING_DBT"
        }        
    )

    TEA_PLANNING_TESTS = create_dbt_task_test(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEA_PLANNING_TESTS"
        }          
    )

    # TEA_PLANNING_ATLAN_UPLOAD = TriggerDagRunOperator(
    #     task_id='TEA_PLANNING_ATLAN_UPLOAD',
    #     trigger_dag_id='SYSTEM_UPDATE_ATLAN',
    #     conf={"domainGuid": domainGuid},
    #     wait_for_completion=True
    # )

    # TEA_PLANNING_DBT >> TEA_PLANNING_TESTS >> TEA_PLANNING_ATLAN_UPLOAD
    
    TEA_PLANNING_DBT >> TEA_PLANNING_TESTS
    
DRIVER_TEA_PLANNING(
    dbt_folder="tea_planning",
    domainGuid="1cc9dfed-5d1e-4112-bc49-5048349169ae"
)