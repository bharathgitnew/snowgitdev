import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.python import get_current_context
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
import include.Python.TelTools_SQLServer as tts

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    exectuion_schedule="30 1 * * *"
    retry_value=0
else:
    exectuion_schedule=None
    retry_value=0

def extract_table_names():
    with open('/usr/local/airflow/include/Configuration/TelTools_SQLServer_LANSWEEPER_Extract.json') as f:
        data=json.load(f)
    return [dataset["table"] for dataset in data["LANSWEEPER"].values()]

@dag(
    start_date=datetime(2024, 9, 6, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["lansweeper"],
)
def DRIVER_LANSWEEPER():

    LANSWEEPER_DBT = TriggerDagRunOperator(
        task_id='LANSWEEPER_DBT',
        trigger_dag_id='DBT_EXECUTION',
        conf={"model_name": "tag:lansweeper --exclude pub.*"},
        wait_for_completion=True
        )
    
    @task(
        map_index_template="{{ lansweeper_map_index }}",
        max_active_tis_per_dag=1
    )
    def EXTRACT_LANSWEEPER(file_path, table_name):
        context = get_current_context()
        context["lansweeper_map_index"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_LANSWEEPER")
        tts.main(file_path, table_name)
        logger.info("Completed EXTRACT_LANSWEEPER")

    EXTRACT_TABLES = EXTRACT_LANSWEEPER.partial(file_path='/usr/local/airflow/include/Configuration/TelTools_SQLServer_LANSWEEPER_Extract.json').expand(table_name=extract_table_names())

    EXTRACT_TABLES >> LANSWEEPER_DBT

DRIVER_LANSWEEPER()