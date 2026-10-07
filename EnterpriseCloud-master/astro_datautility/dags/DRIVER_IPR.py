import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.python import get_current_context
import include.Python.TelTools_SQLServer as tts
from include.Python.dbt_run_operator import create_dbt_task

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    exectuion_schedule="00 2 * * *"
    retry_value=0
else:
    exectuion_schedule=None
    retry_value=0

def extract_tables():
    with open('/usr/local/airflow/include/Configuration/TelTools_SQLServer_IPR_Extract.json') as f:
        data=json.load(f)
    return [dataset["table"] for dataset in data["IPR"].values()]

def extract_tables_2():
    with open('/usr/local/airflow/include/Configuration/TelTools_SQLServer_IPR-VIEWS_Extract.json') as f:
        data=json.load(f)
    return [dataset["table"] for dataset in data["IPR-VIEWS"].values()]

@dag(
    start_date=datetime(2024, 9, 6, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["IPR"],
)
def DRIVER_IPR():

    @task(
        map_index_template="{{ ipr_map_index }}",
        max_active_tis_per_dag=4
    )
    def EXTRACT_IPR(file_path, table_name):
        context = get_current_context()
        context["ipr_map_index"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_IPR")
        tts.main(file_path, table_name)
        logger.info("Completed EXTRACT_IPR")

    EXTRACT_TABLES = EXTRACT_IPR.partial(file_path='/usr/local/airflow/include/Configuration/TelTools_SQLServer_IPR_Extract.json').expand(table_name=extract_tables())
    
    @task(
        map_index_template="{{ ipr_map_index }}",
        max_active_tis_per_dag=4
    )
    def EXTRACT_IPR_VIEWS(file_path, table_name):
        context = get_current_context()
        context["ipr_map_index"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_IPR_VIEWS")
        tts.main(file_path, table_name)
        logger.info("Completed EXTRACT_IPR_VIEWS")

    EXTRACT_TABLES_VIEWS = EXTRACT_IPR_VIEWS.partial(file_path='/usr/local/airflow/include/Configuration/TelTools_SQLServer_IPR-VIEWS_Extract.json').expand(table_name=extract_tables_2())

    EXTRACT_TABLES >> EXTRACT_TABLES_VIEWS

DRIVER_IPR()