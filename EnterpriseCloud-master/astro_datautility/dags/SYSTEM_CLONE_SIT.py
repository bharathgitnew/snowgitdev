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
    tags=["clone_sit"],
)
def SYSTEM_CLONE_SIT():

    CLONE_EXECUTION = TriggerDagRunOperator(
        task_id='CLONE_EXECUTION',
        trigger_dag_id='SYSTEM_SQLFILE_EXECUTION',
        conf={"FileName": "/usr/local/airflow/include/Snowflake/Access/Clone.SIT.sql", "query_tag": "clone_sit"},
        wait_for_completion=True
    )

    CLONE_GRANT = TriggerDagRunOperator(
        task_id='CLONE_GRANT',
        trigger_dag_id='SYSTEM_SQLFILE_EXECUTION',
        conf={"FileName": "/usr/local/airflow/include/Snowflake/Access/Clone.SIT.Grants.sql", "query_tag": "clone_sit"},
        wait_for_completion=True
    )
    
    SERVICE_ACCOUNT_GRANTS = TriggerDagRunOperator(
        task_id='SERVICE_ACCOUNT_GRANTS',
        trigger_dag_id='SYSTEM_SQLFILE_EXECUTION',
        conf={"FileName": "/usr/local/airflow/include/Snowflake/Access/Clone.SIT.Grants.Dynamic.sql", "query_tag": "clone_sit", "is_dynamic": True},
        wait_for_completion=True
    )
    
    POSTADO_PIPELINE = TriggerDagRunOperator(
        task_id='POSTADO_PIPELINE',
        trigger_dag_id='SYSTEM_POSTADO_PIPELINE',
        conf={"pipelineID":"203","branch":"sit"},
        wait_for_completion=True
    )
    
    CLONE_EXECUTION >> CLONE_GRANT >> SERVICE_ACCOUNT_GRANTS >> POSTADO_PIPELINE

SYSTEM_CLONE_SIT()