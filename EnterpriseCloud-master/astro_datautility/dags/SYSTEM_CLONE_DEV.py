import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.bash import BashOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.exceptions import AirflowSkipException


ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']
logger = logging.getLogger("airflow.task")
schedule = '0 20 * * 5' if ASTRO_DEPLOYMENT_NAME == 'PROD' else None

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=schedule,
    catchup=False,
    doc_md=__doc__,
    tags=["clone_dev"],
)
def SYSTEM_CLONE_DEV():

    CLONE_EXECUTION = TriggerDagRunOperator(
        task_id='CLONE_EXECUTION',
        trigger_dag_id='SYSTEM_SQLFILE_EXECUTION',
        conf={"FileName": "/usr/local/airflow/include/Snowflake/Access/Clone.Dev.sql", "query_tag": "clone_dev"},
        wait_for_completion=True
    )

    CLONE_GRANT = TriggerDagRunOperator(
        task_id='CLONE_GRANT',
        trigger_dag_id='SYSTEM_SQLFILE_EXECUTION',
        conf={"FileName": "/usr/local/airflow/include/Snowflake/Access/Clone.Dev.Grants.sql", "query_tag": "clone_dev"},
        wait_for_completion=True
    )
    
    SERVICE_ACCOUNT_GRANTS = TriggerDagRunOperator(
        task_id='SERVICE_ACCOUNT_GRANTS',
        trigger_dag_id='SYSTEM_SQLFILE_EXECUTION',
        conf={"FileName": "/usr/local/airflow/include/Snowflake/Access/Clone.Dev.Grants.Dynamic.sql", "query_tag": "clone_dev", "is_dynamic": True},
        wait_for_completion=True
    )
    
    CLONE_EXECUTION >> CLONE_GRANT >> SERVICE_ACCOUNT_GRANTS

SYSTEM_CLONE_DEV()