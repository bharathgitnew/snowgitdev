import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from include.Python.dbt_run_operator_new_platform import create_dbt_task, create_dbt_task_test

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']
logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    execution_schedule="10 6,11 * * *"
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
    tags=["tmea_equipment_sales"],
)
def DRIVER_TMEA_EQUIPMENT_SALES(dbt_folder,domainGuid):

    # TMEA_EQUIPMENT_SALES_DBT = TriggerDagRunOperator(
    #     task_id='TMEA_EQUIPMENT_SALES_DBT',
    #     trigger_dag_id='DBT_EXECUTION_NEW_PLATFORM',
    #     conf={"model_name": dbt_folder},
    #     wait_for_completion=True,
    #     queue='dbt-queue'
    #     )

    # TMEA_EQUIPMENT_SALES_TESTS = TriggerDagRunOperator(
    #     task_id='TMEA_EQUIPMENT_SALES_TESTS',
    #     trigger_dag_id='DBT_TEST_NEW_PLATFORM',
    #     conf={"model_name": dbt_folder},
    #     wait_for_completion=True
    #     )
    
    TMEA_EQUIPMENT_SALES_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TMEA_EQUIPMENT_SALES_DBT"
        }        
    )

    TMEA_EQUIPMENT_SALES_TESTS = create_dbt_task_test(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TMEA_EQUIPMENT_SALES_TESTS"
        }          
    )

    # TMEA_EQUIPMENT_SALES_ATLAN_UPLOAD = TriggerDagRunOperator(
    #     task_id='TMEA_EQUIPMENT_SALES_ATLAN_UPLOAD',
    #     trigger_dag_id='SYSTEM_UPDATE_ATLAN',
    #     conf={"domainGuid": domainGuid},
    #     wait_for_completion=True
    # )

    # TMEA_EQUIPMENT_SALES_DBT >> TMEA_EQUIPMENT_SALES_TESTS >> TMEA_EQUIPMENT_SALES_ATLAN_UPLOAD
    TMEA_EQUIPMENT_SALES_DBT >> TMEA_EQUIPMENT_SALES_TESTS

DRIVER_TMEA_EQUIPMENT_SALES(dbt_folder="tmea_equipment_sales",domainGuid="56048252-3614-4f20-872b-4987f3fcd169")