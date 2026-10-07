import os
import json
import logging
from pathlib import Path
from pendulum import datetime

from airflow.decorators import dag
from airflow.operators.python import PythonOperator
# from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.utils.task_group import TaskGroup

from include.Python.dbt_run_operator_new_platform import (
    create_dbt_task,
    create_dbt_task_test,
)
import include.Python.TelTools_SQLServer as tts

ASTRO_DEPLOYMENT_NAME: str = os.environ["ASTRO_DEPLOYMENT_NAME"]
logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME == "PROD":
    execution_schedule = "08 2 * * *"
    retry_value = 0
else:
    execution_schedule = None
    retry_value = 0

BASE_DIR = "/usr/local/airflow"
CONFIG_BASE_PATH = os.path.join(BASE_DIR, "include", "Configuration")

EXTRACT_CONFIG_FILE = os.path.join(CONFIG_BASE_PATH, "TelTools_SQLServer_GWS_Extract.json")
EXTRACT_CONFIG_ROOT_KEY = "GWS"

DBT_FOLDER = "ttca_quality"

# # TODO: confirm/replace with the actual Atlan domain GUID for TTCA_QUALITY.
# DOMAIN_GUID = "83f6aba8-4c9e-4561-a84a-f51484e48e27"


def _load_dataset_names(config_path: str, root_key: str) -> list[str]:
    config = json.loads(Path(config_path).read_text())
    return [dataset["table"] for dataset in config[root_key].values()]


def _group_tables(table_names: list[str]) -> dict[str, list[str]]:
    group_a = [t for t in table_names if "gws_" in t.lower()]
    group_b = [t for t in table_names if "imec_" in t.lower() and t not in group_a]
    group_c = [t for t in table_names if t not in group_a and t not in group_b]
    return {"GROUP_A": group_a, "GROUP_B": group_b, "GROUP_C": group_c}


def _extract_table(table_name: str) -> None:
    logger.info("Started extract for %s", table_name)
    tts.main(EXTRACT_CONFIG_FILE, table_name)
    logger.info("Completed extract for %s", table_name)


@dag(
    start_date=datetime(2025, 9, 2, tz="America/Chicago"),
    schedule=execution_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["ttca_quality"],
)
def DRIVER_TTCA_QUALITY():

    TTCA_QUALITY_DBT = create_dbt_task(
        **{
            "Base_directory": os.path.dirname(__file__),
            "model_name": DBT_FOLDER,
            "task_id": "TTCA_QUALITY_DBT",
        }
    )

    TTCA_QUALITY_DBT_TESTS = create_dbt_task_test(
        **{
            "Base_directory": os.path.dirname(__file__),
            "model_name": DBT_FOLDER,
            "task_id": "TTCA_QUALITY_DBT_TESTS",
        }
    )

    # ttca_quality_atlan_upload = TriggerDagRunOperator(
    #     task_id="TTCA_QUALITY_ATLAN_UPLOAD",
    #     trigger_dag_id="SYSTEM_UPDATE_ATLAN",
    #     conf={"domainGuid": DOMAIN_GUID},
    #     wait_for_completion=True,
    # )

    table_names = _load_dataset_names(EXTRACT_CONFIG_FILE, EXTRACT_CONFIG_ROOT_KEY)
    table_groups = _group_tables(table_names)

    with TaskGroup(group_id="extract_tasks") as EXTRACT_TASKS:
        for group_name, tables in table_groups.items():
            with TaskGroup(group_id=group_name):
                for table_name in tables:
                    PythonOperator(
                        task_id=f"{table_name}",
                        python_callable=_extract_table,
                        op_kwargs={"table_name": table_name},
                    )

    # extract_tasks >> ttca_quality_dbt >> ttca_quality_dbt_tests >> ttca_quality_atlan_upload
    EXTRACT_TASKS >> TTCA_QUALITY_DBT >> TTCA_QUALITY_DBT_TESTS

DRIVER_TTCA_QUALITY()