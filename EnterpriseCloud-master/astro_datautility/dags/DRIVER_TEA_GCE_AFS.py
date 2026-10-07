import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.operators.python import get_current_context

from include.Python.getCopyFile import main as copy
from include.Python.dbt_run_operator_new_platform import (
    create_dbt_task,
    create_dbt_task_test,
)
import include.Python.TelTools_SQLServer as tts


ASTRO_DEPLOYMENT_NAME = os.environ["ASTRO_DEPLOYMENT_NAME"]
CONFIG_BASE_PATH = "/usr/local/airflow/include/Configuration"

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME == "PROD":
    execution_schedule = "08 2 * * *"
    retry_value = 0
else:
    execution_schedule = None
    retry_value = 0

def _load_dataset_names(config_filename, root_key):
    full_path = os.path.join(CONFIG_BASE_PATH, config_filename)
    with open(full_path) as f:
        data = json.load(f)
    return [dataset["table"] for dataset in data[root_key].values()]


def extract_madata_silver_dataset_names():
    return _load_dataset_names(
        "TelTools_SQLServer_ADS-MADataSilver_Extract.json",
        "ADS-MADataSilver",
    )


def extract_tffanalytics_dataset_names():
    return _load_dataset_names(
        "TelTools_SQLServer_ADS-TFFanalytics_Extract.json",
        "ADS-TFFanalytics",
    )


def extract_parts_counter_production_dataset_names():
    return _load_dataset_names(
        "TelTools_SQLServer_ADS-Parts_Counter_Production_Extract.json",
        "ADS-Parts_Counter_Production",
    )


def extract_madata_output_production_dataset_names():
    return _load_dataset_names(
        "TelTools_SQLServer_ADS-MADataOutputProduction_Extract.json",
        "ADS-MADataOutputProduction",
    )


def extract_ads_file_names():
    return _load_dataset_names(
        "TelTools_CopyFile_ADS.json",
        "CopyFile",
    )


@dag(
    start_date=datetime(2025, 9, 2, tz="America/Chicago"),
    schedule=execution_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["tea_gce_afs"],
)
def DRIVER_TEA_GCE_AFS(dbt_folder, domainGuid):


    TEA_GCE_AFS_DBT = create_dbt_task(
        **{
            "Base_directory": os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id": "TEA_GCE_AFS_DBT",
        }
    )

    TEA_GCE_AFS_DBT_TESTS = create_dbt_task_test(
        **{
            "Base_directory": os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id": "TEA_GCE_AFS_DBT_TESTS",
        }
    )

    TEA_GCE_AFS_ATLAN_UPLOAD = TriggerDagRunOperator(
        task_id="TEA_GCE_AFS_ATLAN_UPLOAD",
        trigger_dag_id="SYSTEM_UPDATE_ATLAN",
        conf={"domainGuid": domainGuid},
        wait_for_completion=True,
    )

    @task(
        map_index_template="{{ TEA_GCE_AFS_MADATA_SILVER_CUSTOM_MAP_INDEX }}",
        max_active_tis_per_dag=5,
    )
    def EXTRACT_TEA_GCE_AFS_MADATA_SILVER(file_path, table_name):
        context = get_current_context()
        context["TEA_GCE_AFS_MADATA_SILVER_CUSTOM_MAP_INDEX"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_TEA_GCE_AFS_MADATA_SILVER")
        tts.main(file_path, table_name)
        logger.info("Completed EXTRACT_TEA_GCE_AFS_MADATA_SILVER")

    @task(
        map_index_template="{{ TEA_GCE_AFS_TFFANALYTICS_CUSTOM_MAP_INDEX }}",
        max_active_tis_per_dag=2,
    )
    def EXTRACT_TEA_GCE_AFS_TFFANALYTICS(file_path, table_name):
        context = get_current_context()
        context["TEA_GCE_AFS_TFFANALYTICS_CUSTOM_MAP_INDEX"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_TEA_GCE_AFS_TFFANALYTICS")
        tts.main(file_path, table_name)
        logger.info("Completed EXTRACT_TEA_GCE_AFS_TFFANALYTICS")

    @task(
        map_index_template="{{ TEA_GCE_AFS_PARTS_COUNTER_PROD_CUSTOM_MAP_INDEX }}",
        max_active_tis_per_dag=2,
    )
    def EXTRACT_TEA_GCE_AFS_PARTS_COUNTER_PROD(file_path, table_name):
        context = get_current_context()
        context["TEA_GCE_AFS_PARTS_COUNTER_PROD_CUSTOM_MAP_INDEX"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_TEA_GCE_AFS_PARTS_COUNTER_PROD")
        tts.main(file_path, table_name)
        logger.info("Completed EXTRACT_TEA_GCE_AFS_PARTS_COUNTER_PROD")

    @task(
        map_index_template="{{ TEA_GCE_AFS_MADATA_OUTPUT_PROD_CUSTOM_MAP_INDEX }}",
        max_active_tis_per_dag=2,
    )
    def EXTRACT_TEA_GCE_AFS_MADATA_OUTPUT_PROD(file_path, table_name):
        context = get_current_context()
        context["TEA_GCE_AFS_MADATA_OUTPUT_PROD_CUSTOM_MAP_INDEX"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_TEA_GCE_AFS_MADATA_OUTPUT_PROD")
        tts.main(file_path, table_name)
        logger.info("Completed EXTRACT_TEA_GCE_AFS_MADATA_OUTPUT_PROD")

    @task(
        map_index_template="{{ COPYFILE_MAP_INDEX }}",
        max_active_tis_per_dag=2,
    )
    def EXTRACT_COPYFILE(file_path, table_name):
        context = get_current_context()
        context["COPYFILE_MAP_INDEX"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_COPYFILE")
        copy(file_path, table_name)
        logger.info("Completed EXTRACT_COPYFILE")

    EXTRACT_FILES = EXTRACT_COPYFILE.partial(
        file_path=os.path.join(CONFIG_BASE_PATH, "TelTools_CopyFile_ADS.json")
    ).expand(
        table_name=extract_ads_file_names()
    )

    EXTRACT_TABLES_TEA_GCE_AFS_MADATA_SILVER = EXTRACT_TEA_GCE_AFS_MADATA_SILVER.partial(
        file_path=os.path.join(CONFIG_BASE_PATH, "TelTools_SQLServer_ADS-MADataSilver_Extract.json")
    ).expand(
        table_name=extract_madata_silver_dataset_names()
    )

    EXTRACT_TABLES_TEA_GCE_AFS_TFFANALYTICS = EXTRACT_TEA_GCE_AFS_TFFANALYTICS.partial(
        file_path=os.path.join(CONFIG_BASE_PATH, "TelTools_SQLServer_ADS-TFFanalytics_Extract.json")
    ).expand(
        table_name=extract_tffanalytics_dataset_names()
    )

    EXTRACT_TABLES_TEA_GCE_AFS_PARTS_COUNTER_PROD = EXTRACT_TEA_GCE_AFS_PARTS_COUNTER_PROD.partial(
        file_path=os.path.join(CONFIG_BASE_PATH, "TelTools_SQLServer_ADS-Parts_Counter_Production_Extract.json")
    ).expand(
        table_name=extract_parts_counter_production_dataset_names()
    )

    EXTRACT_TABLES_TEA_GCE_AFS_MADATA_OUTPUT_PROD = EXTRACT_TEA_GCE_AFS_MADATA_OUTPUT_PROD.partial(
        file_path=os.path.join(CONFIG_BASE_PATH, "TelTools_SQLServer_ADS-MADataOutputProduction_Extract.json")
    ).expand(
        table_name=extract_madata_output_production_dataset_names()
    )

    [
        EXTRACT_TABLES_TEA_GCE_AFS_MADATA_SILVER,
        EXTRACT_TABLES_TEA_GCE_AFS_TFFANALYTICS,
        EXTRACT_TABLES_TEA_GCE_AFS_PARTS_COUNTER_PROD,
        EXTRACT_TABLES_TEA_GCE_AFS_MADATA_OUTPUT_PROD,
        EXTRACT_FILES,
    ] >> TEA_GCE_AFS_DBT >> TEA_GCE_AFS_DBT_TESTS >> TEA_GCE_AFS_ATLAN_UPLOAD


DRIVER_TEA_GCE_AFS(
    dbt_folder="tea_gce_afs",
    domainGuid="83f6aba8-4c9e-4561-a84a-f51484e48e27",
)
