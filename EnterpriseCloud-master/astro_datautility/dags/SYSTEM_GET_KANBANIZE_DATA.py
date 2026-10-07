import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.bash import BashOperator
from include.Python.getKanbanize import main as getKB
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

@dag(
    start_date=datetime(2025, 10, 7, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    max_active_runs= 1,
    tags=["get_kanbanize"],
)
@task
def SYSTEM_GET_KANBANIZE_DATA():
    logger.info("Started SYSTEM_GET_KANBANIZE_DATA")
    getKB()
    logger.info("Completed SYSTEM_GET_KANBANIZE_DATA")

SYSTEM_GET_KANBANIZE_DATA()