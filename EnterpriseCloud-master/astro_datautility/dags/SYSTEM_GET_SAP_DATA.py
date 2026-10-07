import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.bash import BashOperator
from include.Python.getSapData import main as sapapi
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    tags=["get_sapdata"],
)
@task
def SYSTEM_GET_SAP_DATA(view_name,record_limit,use_replay_queue,archive_file,extract_type):
    logger.info("Started SYSTEM_GET_SAP_DATA")
    sapapi(view_name,record_limit,use_replay_queue,archive_file,extract_type)
    logger.info("Completed SYSTEM_GET_SAP_DATA")

SYSTEM_GET_SAP_DATA(view_name="ALL",record_limit="NotTrue",use_replay_queue="NotTrue",archive_file="false",extract_type="enter_a_value")