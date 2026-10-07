import os
import logging
from airflow.decorators import dag
from pendulum import datetime
from airflow.operators.trigger_dagrun import TriggerDagRunOperator


ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']
logger = logging.getLogger("airflow.task")

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    tags=["environment_setup"],
)
def SYSTEM_ENVIRONMENT_SETUP():

    DEPS_OLD_PLATFORM_DBT = TriggerDagRunOperator(
        task_id='DEPS_OLD_PLATFORM_DBT',
        trigger_dag_id='DBT_DEPS',
        wait_for_completion=True
    )
    
    DEPS_NEW_PLATFORM_DBT = TriggerDagRunOperator(
        task_id='DEPS_NEW_PLATFORM_DBT',
        trigger_dag_id='DBT_DEPS_NEW_PLATFORM',
        wait_for_completion=True
    )

    DBT_VIEW_EXECUTION = TriggerDagRunOperator(
        task_id='DBT_VIEW_EXECUTION',
        trigger_dag_id='DBT_EXECUTION',
        conf={"model_name": "config.materialized:view --exclude logging"},
        wait_for_completion=True
    )
    
    SERVICE_ACCOUNT_GRANTS = TriggerDagRunOperator(
        task_id='SERVICE_ACCOUNT_GRANTS',
        trigger_dag_id='SYSTEM_SQLFILE_EXECUTION',
        conf={"FileName": '/usr/local/airflow/include/Snowflake/Access/ServiceAccount.Grants.sql', 'query_tag': 'svc_grants', 'is_dynamic': True},
        wait_for_completion=True
    )
    
    [DEPS_OLD_PLATFORM_DBT,DEPS_NEW_PLATFORM_DBT] >> DBT_VIEW_EXECUTION >> SERVICE_ACCOUNT_GRANTS

SYSTEM_ENVIRONMENT_SETUP()