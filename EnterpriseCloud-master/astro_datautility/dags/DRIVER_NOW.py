import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.python import get_current_context
import include.Python.TelTools_Oracle as tto
from include.Python.dbt_run_operator import create_dbt_task

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    exectuion_schedule="35 3 * * *"
    retry_value=0
else:
    exectuion_schedule=None
    retry_value=0

def extract_table_names():
    with open('/usr/local/airflow/include/Configuration/TelTools_Oracle_Now_Extract.json') as f:
        data=json.load(f)
    return [dataset["table"] for dataset in data["NOW"].values()]

@dag(
    start_date=datetime(2025, 8, 21, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["now"],
)
def DRIVER_NOW():

    NOW_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name":"tag:now --exclude pub.*",
            "task_id" : "NOW_DBT"
        }
    )

    @task(
        map_index_template="{{ NOW_MAP_INDEX }}",
        max_active_tis_per_dag=1
    )
    def EXTRACT_NOW(file_path, table_name):
        context = get_current_context()
        context["NOW_MAP_INDEX"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_NOW")
        tto.main(file_path, table_name)
        logger.info("Completed EXTRACT_NOW")

    EXTRACT_TABLES = EXTRACT_NOW.partial(file_path='/usr/local/airflow/include/Configuration/TelTools_Oracle_Now_Extract.json').expand(table_name=extract_table_names())

    EXTRACT_TABLES >> NOW_DBT

DRIVER_NOW()