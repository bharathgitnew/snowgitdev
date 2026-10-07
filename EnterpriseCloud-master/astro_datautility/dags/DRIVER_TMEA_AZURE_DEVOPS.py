import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']
logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    execution_schedule="05 04 * * *"
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
    tags=["tmea_azure_devops"],
)
def DRIVER_TMEA_AZURE_DEVOPS(dbt_folder,domainGuid):

    TMEA_AZURE_DEVOPS_EXTRACT = TriggerDagRunOperator(
        task_id='TMEA_AZURE_DEVOPS_EXTRACT',
        trigger_dag_id='SYSTEM_GET_WORK_ITEM_DETAILS',
        wait_for_completion=True
        )

    TMEA_AZURE_DEVOPS_DBT = TriggerDagRunOperator(
        task_id='TMEA_AZURE_DEVOPS_DBT',
        trigger_dag_id='DBT_EXECUTION_NEW_PLATFORM',
        conf={"model_name": dbt_folder},
        wait_for_completion=True
        )
    
    TMEA_AZURE_DEVOPS_EXTRACT >> TMEA_AZURE_DEVOPS_DBT

DRIVER_TMEA_AZURE_DEVOPS(dbt_folder="tag:tmea_azure_devops",domainGuid="584dc17b-59f0-45f7-ab13-e30a67c72da5")