import os
import json
import logging
from pendulum import datetime
from airflow.decorators import dag, task
from include.Python.dbt_run_operator import create_dbt_task
from include.Python.getCopyFile import main as PythonCopyFile
from airflow.operators.python import get_current_context


ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    exectuion_schedule="00 6 * * *"
    retry_value=0
else:
    exectuion_schedule=None
    retry_value=0

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["kronos"],
)
def DRIVER_KRONOS(config_copy_file):

    KRONOS_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name":"tag:kronos --exclude pub.*",
            "task_id" : "KRONOS_DBT"
        }
    )

    @task
    def BUILD_COPY_CONFS(config_copy_file) :
        with open(config_copy_file, 'r') as file:
            data=json.load(file)

        return [
            {
                "config_path": config_copy_file,
                "section": table
            } 
            for table in [
                dataset_key for dataset_key, _ in data["CopyFile"].items()
            ]
        ]

    COPY_CONFIGS = BUILD_COPY_CONFS(config_copy_file)

    @task(
        map_index_template="{{ map_index_copy_file }}",
        max_active_tis_per_dag=6
    )
    def COPY_FILE_KRONOS(config_path, section):
        context = get_current_context()
        context["map_index_copy_file"] = "Extract: " + str(section)
        logger.info(f"Started Copy FIle Section {str(section)}")
        PythonCopyFile(config_path, section)
        logger.info(f"Completed Copy FIle Section {str(section)}")

    COPY_FILE_KRONOS.expand_kwargs(COPY_CONFIGS) >> KRONOS_DBT

DRIVER_KRONOS(
    config_copy_file="/usr/local/airflow/include/Configuration/TelTools_CopyFile_Kronos.json"
)