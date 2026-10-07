import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

import include.Python.TelTools_SQLServer as tts

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    exectuion_schedule="0 3-23/4 * * *"
    retry_value=0
else:
    exectuion_schedule=None
    retry_value=0

def extract_table_names():
    with open('/usr/local/airflow/include/Configuration/TelTools_SQLServer_TIRS_Extract.json') as f:
        data=json.load(f)
    return [dataset["table"] for dataset in data["TIRS"].values()]

def extract_tirs_tmea_table_names():
    with open('/usr/local/airflow/include/Configuration/TelTools_SQLServer_TIRS-TMEA_Extract.json') as f:
        data=json.load(f)
    return [dataset["table"] for dataset in data["TIRS-TMEA"].values()]

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["tirs"],
)
def DRIVER_TIRS():

    TIRS_DBT = TriggerDagRunOperator(
        task_id='TIRS_DBT',
        trigger_dag_id='DBT_EXECUTION',
        conf={"model_name": "tag:tirs common.de_ehs --exclude pub.*"},
        wait_for_completion=True
        )

    @task(
        map_index_template="{{ tirs_map_index }}"
    )
    def EXTRACT_TIRS(file_path, table_name):
        from airflow.operators.python import get_current_context

        context = get_current_context()
        context["tirs_map_index"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_TIRS")
        tts.main(file_path, table_name)
        logger.info("Completed EXTRACT_TIRS")

    EXTRACT_TIRS_DATASETS = EXTRACT_TIRS.partial(file_path='/usr/local/airflow/include/Configuration/TelTools_SQLServer_TIRS_Extract.json').expand(table_name=extract_table_names())
    EXTRACT_TIRS_TMEA_DATASETS = EXTRACT_TIRS.partial(file_path='/usr/local/airflow/include/Configuration/TelTools_SQLServer_TIRS-TMEA_Extract.json').expand(table_name=extract_tirs_tmea_table_names())

    EXTRACT_TIRS_DATASETS >> EXTRACT_TIRS_TMEA_DATASETS >> TIRS_DBT

DRIVER_TIRS()