import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from include.Python.dbt_run_operator_new_platform import create_dbt_task, create_dbt_task_test

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']
logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    execution_schedule="04 7 * * *"
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
    tags=["tea_sales_revenue"],
)
def DRIVER_TEA_SALES_REVENUE(dbt_folder,domainGuid):

    # TEA_SALES_REVENUE_DBT = TriggerDagRunOperator(
    #     task_id='TEA_SALES_REVENUE_DBT',
    #     trigger_dag_id='DBT_EXECUTION_NEW_PLATFORM',
    #     conf={"model_name": dbt_folder},
    #     wait_for_completion=True
    #     )

    # TEA_SALES_REVENUE_TESTS = TriggerDagRunOperator(
    #     task_id='TEA_SALES_REVENUE_TESTS',
    #     trigger_dag_id='DBT_TEST_NEW_PLATFORM',
    #     conf={"model_name": dbt_folder},
    #     wait_for_completion=True
    #     )

    TEA_SALES_REVENUE_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEA_SALES_REVENUE_DBT"
        }        
    )

    TEA_SALES_REVENUE_TESTS = create_dbt_task_test(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEA_SALES_REVENUE_TESTS"
        }          
    )

    TEA_SALES_REVENUE_ATLAN_UPLOAD = TriggerDagRunOperator(
        task_id='TEA_SALES_REVENUE_ATLAN_UPLOAD',
        trigger_dag_id='SYSTEM_UPDATE_ATLAN',
        conf={"domainGuid": domainGuid},
        wait_for_completion=True
    )

    TEA_SALES_REVENUE_DBT >>  TEA_SALES_REVENUE_TESTS >> TEA_SALES_REVENUE_ATLAN_UPLOAD

DRIVER_TEA_SALES_REVENUE(dbt_folder="tea_sales_revenue",domainGuid="abdc989e-b8b7-4009-b439-d7e035a79e3b")