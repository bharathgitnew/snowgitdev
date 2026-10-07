import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.bash import BashOperator
from include.Python.getSharePointFile import main as sp
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    tags=["getSharePointFiles"],
)
@task
def SYSTEM_GET_SHAREPOINT_FILES(job_name):
    logger.info("Started SYSTEM_GET_SHAREPOINT_FILES")
    sp(job_name)
    logger.info("Completed SYSTEM_GET_SHAREPOINT_FILES")

SYSTEM_GET_SHAREPOINT_FILES(job_name="ALL")