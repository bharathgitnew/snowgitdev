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
    exectuion_schedule="15 1 * * *"
    retry_value=0
else:
    exectuion_schedule=None
    retry_value=0

def extract_tables():
    with open('/usr/local/airflow/include/Configuration/TelTools_SQLServer_CARMA_Extract.json') as f:
        data=json.load(f)
    return [dataset["table"] for dataset in data["CARMA"].values()]

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["carma"],
)
def DRIVER_CARMA():

    @task(
        map_index_template="{{ carma_map_index }}",
        max_active_tis_per_dag=2
    )
    def EXTRACT_CARMA(file_path, table_name):
        from airflow.operators.python import get_current_context

        context = get_current_context()
        context["carma_map_index"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_CARMA")
        tts.main(file_path, table_name)
        logger.info("Completed EXTRACT_CARMA")

    CARMA_DBT = create_dbt_task(
            **{
                "Base_directory" : os.path.dirname(__file__),
                "model_name":"tag:carma --exclude pub.*",
                "task_id" : "CARMA_DBT"
            }
        )
    
    EXTRACT_TABLES = EXTRACT_CARMA.partial(file_path='/usr/local/airflow/include/Configuration/TelTools_SQLServer_CARMA_Extract.json').expand(table_name=extract_tables())

    EXTRACT_TABLES >> CARMA_DBT

DRIVER_CARMA()