import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.bash import BashOperator
from include.Python.getCopyFile import main as copy
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    tags=["copy_file"],
)
@task
def SYSTEM_COPY_FILE(config_path,section):
    logger.info("Started SYSTEM_COPY_FILE")
    copy(config_path,section)
    logger.info("Completed SYSTEM_COPY_FILE")

SYSTEM_COPY_FILE(config_path="/usr/local/airflow/include/Configuration/TelTools_CopyFile_File.json",section="STOCK_TEE_CRYSTAL")