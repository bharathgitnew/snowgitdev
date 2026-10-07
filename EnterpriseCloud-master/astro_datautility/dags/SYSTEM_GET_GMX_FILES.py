import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.bash import BashOperator
from include.Python.getGMXFile import main as getGMX 
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.providers.microsoft.azure.hooks.wasb import WasbHook

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

# Set container name and WASB connection ID based on deployment environment for managed identity authentication.

CONTAINER_NAME = 'target'

if ASTRO_DEPLOYMENT_NAME == 'PROD':
    WASB_CONN_ID = "GMX_PROD_BLOB_STORAGE"

else:
    WASB_CONN_ID = "GMX_STAGE_BLOB_STORAGE"

logger = logging.getLogger("airflow.task")

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    tags=["get_gmx_files"],
)
@task
def SYSTEM_GET_GMX_FILES(srcAccount,runType,configPath,threadNum):
    logger.info("Started SYSTEM_GET_GMX_FILES")

    hook = WasbHook(wasb_conn_id=WASB_CONN_ID)
    blob_service_client = hook.get_conn()
    connection_hook = blob_service_client.get_container_client(container=CONTAINER_NAME)

    getGMX(srcAccount,runType, configPath, threadNum, connection_hook)
    logger.info("Completed SYSTEM_GET_GMX_FILES")

SYSTEM_GET_GMX_FILES(
    srcAccount="PROD", 
    runType="DAILY",
    configPath="/usr/local/airflow/include/Configuration/FileUploader_GMX.json",
    threadNum=8
)