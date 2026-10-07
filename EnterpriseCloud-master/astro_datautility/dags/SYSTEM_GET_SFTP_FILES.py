import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.bash import BashOperator
from include.Python.getSFTPFile import main as sftp
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    tags=["get_crm_files"],
)
@task
def SYSTEM_GET_SFTP_FILES(config_path,section):
    logger.info("Started SYSTEM_GET_SFTP_FILES")
    sftp(config_path,section)
    logger.info("Completed SYSTEM_GET_SFTP_FILES")

SYSTEM_GET_SFTP_FILES(config_path="/usr/local/airflow/include/Configuration/TelTools_SFTPFile.json",section="dummy_variable")