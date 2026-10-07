import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from include.Python.dbt_run_operator import create_dbt_task

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    exectuion_schedule="15 0 * * *"
    retry_value=3
else:
    exectuion_schedule=None
    retry_value=0

@dag(
    start_date=datetime(2025, 9, 2, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["AzureAD"],
)
def DRIVER_AZUREAD(resource_name):

    AZUREAD_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name":"ods.activedirectory",
            "task_id" : "AZUREAD_DBT"
        }
    )
    
    GET_AZUREAD = TriggerDagRunOperator(
        task_id='GET_AZUREAD',
        trigger_dag_id='SYSTEM_GET_MSGRAPH_DATA',
        conf={"resource_name": resource_name},
        wait_for_completion=True
    )
    
    GET_AZUREAD >> AZUREAD_DBT

DRIVER_AZUREAD(resource_name="get_az_active_directory")