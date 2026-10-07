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
    exectuion_schedule="45 2 * * *"
    retry_value=0
else:
    exectuion_schedule=None
    retry_value=0

def extract_tables():
    with open('/usr/local/airflow/include/Configuration/TelTools_SQLServer_CSDPRO_Extract.json') as f:
        data=json.load(f)
    return [dataset["table"] for dataset in data["CSDPRO"].values()]

@dag(
    start_date=datetime(2024, 9, 6, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["csdpro"],
)
def DRIVER_CSDPRO():

    CSDPRO_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name":"tag:csdpro --exclude pub.*",
            "task_id" : "CSDPRO_DBT"
        }
    )

    @task(
        map_index_template="{{ csdrpro_map_index }}",
        max_active_tis_per_dag=2
    )
    def EXTRACT_CSDPRO(file_path, table_name):
        context = get_current_context()
        context["csdrpro_map_index"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_CSDPRO")
        tts.main(file_path, table_name)
        logger.info("Completed EXTRACT_CSDPRO")

    EXTRACT_TABLES = EXTRACT_CSDPRO.partial(file_path='/usr/local/airflow/include/Configuration/TelTools_SQLServer_CSDPRO_Extract.json').expand(table_name=extract_tables())

    EXTRACT_TABLES >> CSDPRO_DBT

DRIVER_CSDPRO()