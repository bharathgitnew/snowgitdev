import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.bash import BashOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.exceptions import AirflowSkipException
from airflow.operators.python import get_current_context

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    exectuion_schedule="0 2,6,10,15,19 * * *"
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
    tags=["finance"],
)
def DRIVER_FINANCE_RUNS(view_name,record_limit,use_replay_queue,archive_file,extract_type):

    FINANCE_DBT = TriggerDagRunOperator(
        task_id='FINANCE_DBT',
        trigger_dag_id='DBT_EXECUTION',
        conf={"model_name": "tag:finance"},
        wait_for_completion=True
        )

    FINACE_EXTRACT = TriggerDagRunOperator(
            task_id='FINACE_EXTRACT',
            trigger_dag_id='SYSTEM_GET_SAP_DATA',
            conf={"view_name":view_name,"record_limit":record_limit,"use_replay_queue":use_replay_queue,"archive_file":archive_file,"extract_type":extract_type},
            wait_for_completion=True
        )
    
    FINACE_EXTRACT >> FINANCE_DBT

DRIVER_FINANCE_RUNS(view_name="ALL",record_limit="NotTrue",use_replay_queue="NotTrue",archive_file="false",extract_type="finance")