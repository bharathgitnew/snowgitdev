import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from include.Python.dbt_run_operator import create_dbt_task

import include.Python.TelTools_SQLServer as tts

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    exectuion_schedule="20 1 * * *"
    retry_value=0
else:
    exectuion_schedule=None
    retry_value=0

def extract_table_names():
    with open('/usr/local/airflow/include/Configuration/TelTools_SQLServer_ROSETTA_Extract.json') as f:
        data=json.load(f)
    return [dataset["table"] for dataset in data["ROSETTA"].values()]

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["rosetta"],
)
def DRIVER_ROSETTA():

    ROSETTA_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name":"tag:rosetta --exclude pub.*",
            "task_id" : "ROSETTA_DBT"
        }
    )

    @task(
        map_index_template="{{ rosetta_map_index }}"
    )
    def EXTRACT_ROSETTA(file_path, table_name):
        from airflow.operators.python import get_current_context

        context = get_current_context()
        context["rosetta_map_index"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_ROSETTA")
        tts.main(file_path, table_name)
        logger.info("Completed EXTRACT_ROSETTA")

    EXTRACT_TABLES = EXTRACT_ROSETTA.partial(file_path='/usr/local/airflow/include/Configuration/TelTools_SQLServer_ROSETTA_Extract.json').expand(table_name=extract_table_names())

    EXTRACT_TABLES >> ROSETTA_DBT

DRIVER_ROSETTA()