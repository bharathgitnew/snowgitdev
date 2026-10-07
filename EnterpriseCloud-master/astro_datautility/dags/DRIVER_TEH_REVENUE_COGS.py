import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']
logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    execution_schedule="05 6 * * *"
    retry_value=3
else:
    execution_schedule=None
    retry_value=0
@dag(
    start_date=datetime(2025, 11, 24, tz="America/Chicago"),
    schedule=execution_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["teh_revenue_cogs"],
)
def DRIVER_TEH_REVENUE_COGS(dbt_folder,domainGuid):

    TEH_REVENUE_COGS_DBT = TriggerDagRunOperator(
        task_id='TEH_REVENUE_COGS_DBT',
        trigger_dag_id='DBT_EXECUTION_NEW_PLATFORM',
        conf={"model_name": dbt_folder},
        wait_for_completion=True
        )

    TEH_REVENUE_COGS_TESTS = TriggerDagRunOperator(
        task_id='TEH_REVENUE_COGS_TESTS',
        trigger_dag_id='DBT_TEST_NEW_PLATFORM',
        conf={"model_name": dbt_folder},
        wait_for_completion=True
        )

    TEH_REVENUE_COGS_ATLAN_UPLOAD = TriggerDagRunOperator(
        task_id='TEH_REVENUE_COGS_ATLAN_UPLOAD',
        trigger_dag_id='SYSTEM_UPDATE_ATLAN',
        conf={"domainGuid": domainGuid},
        wait_for_completion=True
    )

    TEH_REVENUE_COGS_DBT >> TEH_REVENUE_COGS_TESTS >> TEH_REVENUE_COGS_ATLAN_UPLOAD
    
DRIVER_TEH_REVENUE_COGS(dbt_folder="teh_revenue_cogs",domainGuid="a2050875-d2da-4a90-868c-e6d4b431ad25")