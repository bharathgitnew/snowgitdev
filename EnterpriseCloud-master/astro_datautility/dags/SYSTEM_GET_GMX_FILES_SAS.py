import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.bash import BashOperator
from include.Python.getGMXFileSAS import main as getGMX 
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    tags=["get_gmx_files"],
)
@task
def SYSTEM_GET_GMX_FILES_SAS(srcAccount,runType,configPath,threadNum):
    logger.info("Started SYSTEM_GET_GMX_FILES_SAS")
    getGMX(srcAccount,runType, configPath, threadNum)
    logger.info("Completed SYSTEM_GET_GMX_FILES_SAS")

SYSTEM_GET_GMX_FILES_SAS(
    srcAccount="PROD", 
    runType="DAILY",
    configPath="/usr/local/airflow/include/Configuration/FileUploader_GMX.json",
    threadNum=8
)