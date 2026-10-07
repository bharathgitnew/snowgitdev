import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.bash import BashOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    retry_value=3
else:
    retry_value=0

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["GMX"],
)
def DRIVER_GMX(view_name,record_limit,use_replay_queue,archive_file,extract_type,srcAccount,runType,configPath,threadNum):
    
    GMX_EXTRACT = TriggerDagRunOperator(
            task_id='GMX_EXTRACT',
            trigger_dag_id='SYSTEM_GET_GMX_FILES',
            conf={"srcAccount":srcAccount,"runType":runType,"configPath":configPath,"threadNum":threadNum},
            wait_for_completion=True
        )
    
    GMX_DBT = TriggerDagRunOperator(
        task_id='GMX_DBT',
        trigger_dag_id='DBT_EXECUTION',
        conf={"model_name": "tag:sapapi+ tag:gmx+ common.reports common.shared_datasets --exclude common.reports_fin01 common.de_sales_operations tag:finance tag:first_of_month pub.*"},
        wait_for_completion=True
        )

    # EXTRACT_VALIDATOR = TriggerDagRunOperator(
    #         task_id='EXTRACT_VALIDATOR',
    #         trigger_dag_id='SYSTEM_GMX_EXTRACT_VALIDATOR',
    #         conf={"runType":runType},
    #         wait_for_completion=True
    #     )    

    GMX_EXTRACT >> GMX_DBT
    # GMX_EXTRACT >> GMX_DBT >> EXTRACT_VALIDATOR

DRIVER_GMX(view_name="ALL",record_limit="Not True",use_replay_queue="Not True",archive_file="false",extract_type="daily",srcAccount="PROD",runType="DAILY",configPath="/usr/local/airflow/include/Configuration/FileUploader_GMX.json",threadNum=8)