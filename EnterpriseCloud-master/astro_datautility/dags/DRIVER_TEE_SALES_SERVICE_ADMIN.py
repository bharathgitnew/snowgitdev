import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from include.Python.dbt_run_operator_new_platform import create_dbt_task, create_dbt_task_test

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']
logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    execution_schedule="55 6 * * *"
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
    tags=["tee_sales_service_admin"],
)
def DRIVER_TEE_SALES_SERVICE_ADMIN(dbt_folder, domainGuid):


    TEE_SALES_SERVICE_ADMIN_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEE_SALES_SERVICE_ADMIN_DBT"
        }        
    )

    TEE_SALES_SERVICE_ADMIN_TESTS = create_dbt_task_test(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEE_SALES_SERVICE_ADMIN_TESTS"
        }          
    )

    # TEE_SALES_SERVICE_ADMIN_ATLAN_UPLOAD = TriggerDagRunOperator(
    #     task_id='TEE_SALES_SERVICE_ADMIN_ATLAN_UPLOAD',
    #     trigger_dag_id='SYSTEM_UPDATE_ATLAN',
    #     conf={"domainGuid": domainGuid},
    #     wait_for_completion=True
    # )

    # TEE_SALES_SERVICE_ADMIN_DBT >> TEE_SALES_SERVICE_ADMIN_TESTS >> TEE_SALES_SERVICE_ADMIN_ATLAN_UPLOAD
    
    TEE_SALES_SERVICE_ADMIN_DBT >> TEE_SALES_SERVICE_ADMIN_TESTS
    
DRIVER_TEE_SALES_SERVICE_ADMIN(
    dbt_folder="tee_sales_service_admin",
    domainGuid="c9ba2c58-5329-4a71-bc98-dff468d131cd"
)