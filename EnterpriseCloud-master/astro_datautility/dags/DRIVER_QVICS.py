import os
import json
import logging
from pendulum import datetime

from airflow.decorators import dag, task
from airflow.operators.python import get_current_context

from include.Python.dbt_run_operator import create_dbt_task
import include.Python.TelTools_SQLServer as tts

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    exectuion_schedule="0 0 * * *"
    retry_value=0

else:
    exectuion_schedule=None
    retry_value=0

# def extract_qvics_dataset_names():
#     with open('/usr/local/airflow/include/Configuration/TelTools_SQLServer_QVICS_Extract.json') as f:
#         data=json.load(f)
#     return [dataset["table"] for dataset in data["QVICS"].values()]

# def extract_qvics_tmea_dataset_names():
#     with open('/usr/local/airflow/include/Configuration/TelTools_SQLServer_QVICS-TMEA_Extract.json') as f:
#         data=json.load(f)
#     return [dataset["table"] for dataset in data["QVICS-TMEA"].values()]

def extract_qvics_new_dataset_names():
    with open('/usr/local/airflow/include/Configuration/TelTools_SQLServer_QVICS-NEW_Extract.json') as f:
        data=json.load(f)
    return [dataset["table"] for dataset in data["QVICS-NEW"].values()]

@dag(
    start_date=datetime(2025, 9, 2, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["qvics"],
)
def DRIVER_QVICS():


    QVICS_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name":"tag:qvics --exclude pub.*",
            "task_id" : "QVICS_DBT"
        }
    )

    @task(
        map_index_template="{{ QVICS_CUSTOM_MAP_INDEX }}",
        max_active_tis_per_dag=2
    )
    def EXTRACT_QVICS(file_path, table_name):
        context = get_current_context()
        context["QVICS_CUSTOM_MAP_INDEX"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_QVICS")
        tts.main(file_path, table_name)
        logger.info("Completed EXTRACT_QVICS")

    # @task(
    #     map_index_template="{{ QVICS__TMEA_CUSTOM_MAP_INDEX }}",
    #     max_active_tis_per_dag=2
    # )
    # def EXTRACT_QVICS_TMEA(file_path, table_name):
    #     from airflow.operators.python import get_current_context

    #     context = get_current_context()
    #     context["QVICS__TMEA_CUSTOM_MAP_INDEX"] = "Extract: " + str(table_name)
    #     logger.info("Started EXTRACT_QVICS_TMEA")
    #     tts.main(file_path, table_name)
    #     logger.info("Completed EXTRACT_QVICS_TMEA")

    # EXTRACT_TABLES_QVICS = EXTRACT_QVICS.partial(file_path='/usr/local/airflow/include/Configuration/TelTools_SQLServer_QVICS_Extract.json').expand(table_name=extract_qvics_dataset_names())
    # EXTRACT_TABLES_QVICS_TMEA = EXTRACT_QVICS_TMEA.partial(file_path='/usr/local/airflow/include/Configuration/TelTools_SQLServer_QVICS-TMEA_Extract.json').expand(table_name=extract_qvics_tmea_dataset_names())
    # [EXTRACT_TABLES_QVICS] >> EXTRACT_TABLES_QVICS_TMEA >> QVICS_DBT

    EXTRACT_TABLES_QVICS = EXTRACT_QVICS.partial(file_path='/usr/local/airflow/include/Configuration/TelTools_SQLServer_QVICS-NEW_Extract.json').expand(table_name=extract_qvics_new_dataset_names()) 

    EXTRACT_TABLES_QVICS >> QVICS_DBT


DRIVER_QVICS()