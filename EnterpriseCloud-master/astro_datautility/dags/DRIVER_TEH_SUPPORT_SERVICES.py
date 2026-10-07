import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from include.Python.dbt_run_operator_new_platform import create_dbt_task, create_dbt_task_test

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']
logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    execution_schedule="34 7-22/3 * * *"
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
    tags=["teh_support_services", "ServiceNow"],
)
def DRIVER_TEH_SUPPORT_SERVICES():
    dbt_folder = "teh_support_services"
    domainGuid = "e78c05b7-9d08-4375-a87a-0c7a6df5e11c"
    
    TEH_SUPPORT_SERVICES_SN = TriggerDagRunOperator(
        task_id='TEH_SUPPORT_SERVICES_SN',
        trigger_dag_id='SYSTEM_GET_SERVICENOW_DATA',
        wait_for_completion=True,
    )

    TEH_SUPPORT_SERVICES_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEH_SUPPORT_SERVICES_DBT"
        }        
    )

    TEH_SUPPORT_SERVICES_TESTS = create_dbt_task_test(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEH_SUPPORT_SERVICES_TESTS"
        }          
    )

    TEH_SUPPORT_SERVICES_ATLAN_UPLOAD = TriggerDagRunOperator(
        task_id='TEH_SUPPORT_SERVICES_ATLAN_UPLOAD',
        trigger_dag_id='SYSTEM_UPDATE_ATLAN',
        conf={"domainGuid": domainGuid},
        wait_for_completion=True
    )

    TEH_SUPPORT_SERVICES_SN >> TEH_SUPPORT_SERVICES_DBT >> TEH_SUPPORT_SERVICES_TESTS >> TEH_SUPPORT_SERVICES_ATLAN_UPLOAD
    
DRIVER_TEH_SUPPORT_SERVICES()