import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.bash import BashOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

import include.Python.TelTools_Oracle as tto

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    exectuion_schedule="57 1 * * *"
    retry_value=0
else:
    exectuion_schedule=None
    retry_value=0

def extract_table_names():
    with open('/usr/local/airflow/include/Configuration/TelTools_Oracle_Wisdom_Extract.json') as f:
        data=json.load(f)
    return [dataset["table"] for dataset in data["WISDOM"].values()]

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["wisdom"],
)
def DRIVER_WISDOM():

    WISDOM_DBT = TriggerDagRunOperator(
        task_id='WISDOM_DBT',
        trigger_dag_id='DBT_EXECUTION',
        conf={"model_name": "tag:wisdom common.de_wisdom --exclude pub.*"},
        wait_for_completion=True
        )

    @task(
        map_index_template="{{ wisdom_map_index }}"
    )
    def EXTRACT_WISDOM(file_path, table_name):
        from airflow.operators.python import get_current_context

        context = get_current_context()
        context["wisdom_map_index"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_WISDOM")
        tto.main(file_path, table_name)
        logger.info("Completed EXTRACT_WISDOM")

    EXTRACT_TABLES = EXTRACT_WISDOM.partial(file_path='/usr/local/airflow/include/Configuration/TelTools_Oracle_Wisdom_Extract.json').expand(table_name=extract_table_names())

    EXTRACT_TABLES >> WISDOM_DBT

DRIVER_WISDOM()