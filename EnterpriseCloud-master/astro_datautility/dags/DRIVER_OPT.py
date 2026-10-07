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
    exectuion_schedule="0 */2 * * 1-5"
    retry_value=0
else:
    exectuion_schedule=None
    retry_value=0

def extract_table_names():
    with open('/usr/local/airflow/include/Configuration/TelTools_SQLServer_OPT-SALES_Extract.json') as f:
        data=json.load(f)
    return [dataset["table"] for dataset in data["OPT-SALES"].values()]

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["opt"],
)
def DRIVER_OPT():
    
    OPT_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name":"tag:opt --exclude pub.*",
            "task_id" : "OPT_DBT"
        }
    )

    @task(
        map_index_template="{{ OPT_MAP_INDEX }}"
    )
    def EXTRACT_OPT(file_path, table_name):
        from airflow.operators.python import get_current_context

        context = get_current_context()
        context["OPT_MAP_INDEX"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_OPT")
        tts.main(file_path, table_name)
        logger.info("Completed EXTRACT_OPT")

    EXTRACT_TABLES = EXTRACT_OPT.partial(file_path='/usr/local/airflow/include/Configuration/TelTools_SQLServer_OPT-SALES_Extract.json').expand(table_name=extract_table_names())

    EXTRACT_TABLES >> OPT_DBT

DRIVER_OPT()