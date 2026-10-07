import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.bash import BashOperator
from include.Python.getDevOpsData import main as gwid
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    tags=["get_devops_data"],
)
@task
def SYSTEM_GET_DEVOPS_DATA():
    logger.info("Started SYSTEM_GET_DEVOPS_DATA")
    gwid()
    logger.info("Completed SYSTEM_GET_DEVOPS_DATA")

SYSTEM_GET_DEVOPS_DATA()