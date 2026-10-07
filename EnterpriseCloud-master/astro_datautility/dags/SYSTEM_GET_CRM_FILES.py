import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.bash import BashOperator
from include.Python.getCRMFile import main as crm_file
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    max_active_runs= 1,
    tags=["get_crm_files"],
)
@task
def SYSTEM_GET_CRM_FILES(srcAccount,previousRun,finalRun,entities,entityThreaded):
    logger.info("Started SYSTEM_GET_CRM_FILES")
    crm_file(srcAccount,previousRun, finalRun, entities, entityThreaded)
    logger.info("Completed SYSTEM_GET_CRM_FILES")

SYSTEM_GET_CRM_FILES(srcAccount="PROD1", previousRun="",finalRun="",entities=[],entityThreaded=True)