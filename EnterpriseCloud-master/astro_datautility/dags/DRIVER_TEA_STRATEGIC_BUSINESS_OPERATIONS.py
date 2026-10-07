import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
#from include.Python.getKanbanize import main as getKB
from include.Python.dbt_run_operator_new_platform import create_dbt_task, create_dbt_task_test

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']
logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    execution_schedule="08 7 * * *"
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
    tags=["tea_strategic_business_operations"],
)
def DRIVER_TEA_STRATEGIC_BUSINESS_OPERATIONS(dbt_folder,domainGuid):

    TEA_STRATEGIC_BUSINESS_OPERATIONS_EXTRACT_ATLAN = TriggerDagRunOperator(
        task_id='TEA_STRATEGIC_BUSINESS_OPERATIONS_EXTRACT_ATLAN',
        trigger_dag_id='SYSTEM_GET_ATLAN_DATA',
        conf={"table_name":None, "full_refresh":False},
        wait_for_completion=True
    )
    # @task
    # def TEA_STRATEGIC_BUSINESS_OPERATIONS_EXTRACT_KANBAN():
    #     logger.info("Started TEA_STRATEGIC_BUSINESS_OPERATIONS_EXTRACT_KANBAN")
    #     getKB()
    #     logger.info("Completed TEA_STRATEGIC_BUSINESS_OPERATIONS_EXTRACT_KANBAN")

    # TEA_STRATEGIC_BUSINESS_OPERATIONS_DBT = TriggerDagRunOperator(
    #     task_id='TEA_STRATEGIC_BUSINESS_OPERATIONS_DBT',
    #     trigger_dag_id='DBT_EXECUTION_NEW_PLATFORM',
    #     conf={"model_name": dbt_folder},
    #     wait_for_completion=True
    #     )

    # TEA_STRATEGIC_BUSINESS_OPERATIONS_TESTS = TriggerDagRunOperator(
    #     task_id='TEA_STRATEGIC_BUSINESS_OPERATIONS_TESTS',
    #     trigger_dag_id='DBT_TEST_NEW_PLATFORM',
    #     conf={"model_name": dbt_folder},
    #     wait_for_completion=True
    #     )

    TEA_STRATEGIC_BUSINESS_OPERATIONS_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEA_STRATEGIC_BUSINESS_OPERATIONS_DBT"
        }        
    )

    TEA_STRATEGIC_BUSINESS_OPERATIONS_TESTS = create_dbt_task_test(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEA_STRATEGIC_BUSINESS_OPERATIONS_TESTS"
        }          
    )

    TEA_STRATEGIC_BUSINESS_OPERATIONS_ATLAN_UPLOAD = TriggerDagRunOperator(
        task_id='TEA_STRATEGIC_BUSINESS_OPERATIONS_ATLAN_UPLOAD',
        trigger_dag_id='SYSTEM_UPDATE_ATLAN',
        conf={"domainGuid": domainGuid},
        wait_for_completion=True
    )

    TEA_STRATEGIC_BUSINESS_OPERATIONS_EXTRACT_ATLAN >> TEA_STRATEGIC_BUSINESS_OPERATIONS_DBT >> TEA_STRATEGIC_BUSINESS_OPERATIONS_TESTS >> TEA_STRATEGIC_BUSINESS_OPERATIONS_ATLAN_UPLOAD

DRIVER_TEA_STRATEGIC_BUSINESS_OPERATIONS(dbt_folder="tea_strategic_business_operations",domainGuid="8d1fe5b0-3202-4937-a42c-aa1138b31afb")