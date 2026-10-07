import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from include.Python.dbt_run_operator import create_dbt_task

import include.Python.getITHDFile as get_ithd
import include.Python.TelTools_SQLServer as tts
from include.Python.getMSGraphData import main as getMS

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    exectuion_schedule="05 06 * * *"
    retry_value=0
else:
    exectuion_schedule=None
    retry_value=0

def extract_table_names():
    with open('/usr/local/airflow/include/Configuration/TelTools_SQLServer_TGIS_Extract.json') as f:
        data=json.load(f)
    return [dataset["table"] for dataset in data["TGIS"].values()]

@dag(
    start_date=datetime(2024, 9, 6, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["tgis"],
)
def DRIVER_TGIS():

    TGIS_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": "tag:tgis --exclude pub.*",
            "task_id" : "TGIS_DBT"
        }
    )

    @task(
        map_index_template="{{ ithd_map_index }}",
        max_active_tis_per_dag=1
    )
    def TGIS_EXTRACT(file_path, table_name):
        from airflow.operators.python import get_current_context

        context = get_current_context()
        context["ithd_map_index"] = "Extract: " + str(table_name)
        logger.info("Started TelTools_SQLServer.py.")
        tts.main(file_path, table_name)
        logger.info("Started TelTools_SQLServer.py.")

    TGIS_EXTRACTS = TGIS_EXTRACT.partial(file_path='/usr/local/airflow/include/Configuration/TelTools_SQLServer_TGIS_Extract.json').expand(table_name=extract_table_names())


    TGIS_EXTRACTS >> TGIS_DBT

DRIVER_TGIS()