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
def DRIVER_GMX_ON_DEMAND(srcAccount,runType,configPath,threadNum):
    
    GMX_ON_DEMAND_EXTRACT = TriggerDagRunOperator(
            task_id='GMX_ON_DEMAND_EXTRACT',
            trigger_dag_id='SYSTEM_GET_GMX_FILES',
            conf={"srcAccount":srcAccount,"runType":runType,"configPath":configPath,"threadNum":threadNum},
            wait_for_completion=True
        )
    
    GMX_ON_DEMAND_DBT = TriggerDagRunOperator(
        task_id='GMX_ON_DEMAND_DBT',
        trigger_dag_id='DBT_EXECUTION',
        conf={"model_name": "tag:on_demand+ tag:finance_gmx --exclude pub.*"},
        wait_for_completion=True
        )

    EXTRACT_VALIDATOR_ON_DEMAND = TriggerDagRunOperator(
            task_id='EXTRACT_VALIDATOR_ON_DEMAND',
            trigger_dag_id='SYSTEM_GMX_EXTRACT_VALIDATOR',
            conf={"runType":runType},
            wait_for_completion=True
        )    

    GMX_ON_DEMAND_EXTRACT >> GMX_ON_DEMAND_DBT >> EXTRACT_VALIDATOR_ON_DEMAND

DRIVER_GMX_ON_DEMAND(srcAccount="PROD",runType="ON_DEMAND",configPath="/usr/local/airflow/include/Configuration/FileUploader_GMX_ONDEMAND.json",threadNum=8)