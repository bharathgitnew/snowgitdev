import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.bash import BashOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.exceptions import AirflowSkipException


ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']
logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    exectuion_schedule="30 4 * * *"
    retry_value=3
else:
    exectuion_schedule=None
    retry_value=0
@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["system_snowflake"],
)
def SYSTEM_SNOWFLAKE():

    SNOWFLAKE_DBT = TriggerDagRunOperator(
        task_id='SNOWFLAKE_DBT',
        trigger_dag_id='DBT_EXECUTION',
        conf={"model_name": "tag:snowflake --exclude pub.*"},
        wait_for_completion=True
        )

    SNOWFLAKE_DBT

SYSTEM_SNOWFLAKE()