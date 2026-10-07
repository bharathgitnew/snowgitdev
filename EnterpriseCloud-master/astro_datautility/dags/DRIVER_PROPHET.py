import os
import logging
import json
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.python import get_current_context
from include.Python.dbt_run_operator import create_dbt_task
from include.Python.getCopyFile import main as PythonCopyFile

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    exectuion_schedule="00 1 * * *"
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
    tags=["file"],
)
def DRIVER_PROPHET(config_copy_file):

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
        max_active_tis_per_dag=4
    )
    def COPY_FILE_PROPHET(config_path, section):
        context = get_current_context()
        context["map_index_copy_file"] = "Extract: " + str(section)
        logger.info(f"Started Copy FIle Section {str(section)}")
        PythonCopyFile(config_path, section)
        logger.info(f"Completed Copy FIle Section {str(section)}")

    PROPHET_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name":"tag:prophet --exclude pub.*",
            "task_id" : "PROPHET_DBT"
        }
    )


    COPY_FILE_PROPHET.expand_kwargs(COPY_CONFIGS) >> PROPHET_DBT

DRIVER_PROPHET(config_copy_file="/usr/local/airflow/include/Configuration/TelTools_CopyFile_Prophet.json")