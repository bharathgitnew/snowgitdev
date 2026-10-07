import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.bash import BashOperator
from include.Python.gmxExtractValidator import main as gmxTest
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    tags=["gmx_extract_validator"],
)
@task
def SYSTEM_GMX_EXTRACT_VALIDATOR(runType):
    logger.info("Started SYSTEM_GMX_EXTRACT_VALIDATOR")
    gmxTest(runType)
    logger.info("Completed SYSTEM_GMX_EXTRACT_VALIDATOR")

SYSTEM_GMX_EXTRACT_VALIDATOR(runType="DAILY")