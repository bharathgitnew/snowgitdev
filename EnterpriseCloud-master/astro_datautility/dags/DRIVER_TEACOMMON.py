import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.python import get_current_context
from include.Python.dbt_run_operator import create_dbt_task
import include.Python.TelTools_SQLServer as tts

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    exectuion_schedule="01 3 * * *"
    retry_value=0
else:
    exectuion_schedule=None
    retry_value=0

def extract_table_names():
    with open('/usr/local/airflow/include/Configuration/TelTools_SQLServer_TEACOMMON_Extract.json') as f:
        data=json.load(f)
    return [dataset["table"] for dataset in data["TEACOMMON"].values()]

@dag(
    start_date=datetime(2024, 9, 6, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["teacommon"],
)
def DRIVER_TEACOMMON():

    TEACOMMON_DBT = create_dbt_task(
            **{
                "Base_directory" : os.path.dirname(__file__),
                "model_name":"tag:teacommon --exclude pub.*",
                "task_id" : "TEACOMMON_DBT"
            }
        )
    
    @task(
        map_index_template="{{ teacommon_custom_map_index }}",
        max_active_tis_per_dag=1
    )
    def EXTRACT_TEACOMMON(file_path, table_name):
        context = get_current_context()
        context["teacommon_custom_map_index"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_TEACOMMON")
        tts.main(file_path, table_name)
        logger.info("Completed EXTRACT_TEACOMMON")

    EXTRACT_TABLES = EXTRACT_TEACOMMON.partial(file_path='/usr/local/airflow/include/Configuration/TelTools_SQLServer_TEACOMMON_Extract.json').expand(table_name=extract_table_names())

    EXTRACT_TABLES >> TEACOMMON_DBT

DRIVER_TEACOMMON()