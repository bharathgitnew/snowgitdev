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
    exectuion_schedule="25 1 * * *"
    retry_value=0
else:
    exectuion_schedule=None
    retry_value=0

def extract_table_names():
    with open('/usr/local/airflow/include/Configuration/TelTools_SQLServer_GEM_Extract.json') as f:
        data=json.load(f)
    return [dataset["table"] for dataset in data["GEM"].values()]

@dag(
    start_date=datetime(2024, 9, 6, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["gem"],
)
def DRIVER_GEM():

    GEM_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name":"tag:gem --exclude pub.*",
            "task_id" : "GEM_DBT"
        }
    )

    @task(
        map_index_template="{{ gem_map_index }}",
        max_active_tis_per_dag=1
    )
    def EXTRACT_GEM(file_path, table_name):
        context = get_current_context()
        context["gem_map_index"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_GEM")
        tts.main(file_path, table_name)
        logger.info("Completed EXTRACT_GEM")

    EXTRACT_TABLES = EXTRACT_GEM.partial(file_path='/usr/local/airflow/include/Configuration/TelTools_SQLServer_GEM_Extract.json').expand(table_name=extract_table_names())

    EXTRACT_TABLES >> GEM_DBT

DRIVER_GEM()