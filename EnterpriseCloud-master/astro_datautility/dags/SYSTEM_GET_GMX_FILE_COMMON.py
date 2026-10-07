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

# DAG created to solve the issue - GMX archiving COMMON/ files before triggering the DAILY job. Due to which we are missing files for PARTS_EXPORTIMPORT TABLE.
CONTAINER_NAME = 'target'

if ASTRO_DEPLOYMENT_NAME == 'PROD':
    WASB_CONN_ID = "GMX_PROD_BLOB_STORAGE"
    #exectuion_schedule="00 4 * * *" #disabling the job
    exectuion_schedule=None
else:
    WASB_CONN_ID = "GMX_STAGE_BLOB_STORAGE"
    exectuion_schedule=None

logger = logging.getLogger("airflow.task")

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    tags=["get_gmx_file_common"],
)
@task
def SYSTEM_GET_GMX_FILE_COMMON():
    logger.info("Started SYSTEM_GET_GMX_FILE_COMMON")

    hook = WasbHook(wasb_conn_id=WASB_CONN_ID)
    blob_service_client = hook.get_conn()
    connection_hook = blob_service_client.get_container_client(container=CONTAINER_NAME)
    
    srcAccount="PROD" 
    runType="COMMON"
    configPath="/usr/local/airflow/include/Configuration/FileUploader_GMX.json"
    threadNum=2
    
    getGMX(srcAccount,runType, configPath, threadNum, connection_hook)
    logger.info("Completed SYSTEM_GET_GMX_FILE_COMMON")

SYSTEM_GET_GMX_FILE_COMMON()