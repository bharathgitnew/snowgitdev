import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.operators.python import get_current_context

from include.Python.dbt_run_operator_new_platform import (
    create_dbt_task,
)
import include.Python.TelTools_SQLServer as tts


ASTRO_DEPLOYMENT_NAME = os.environ["ASTRO_DEPLOYMENT_NAME"]
CONFIG_BASE_PATH = "/usr/local/airflow/include/Configuration"

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME == "PROD":
    execution_schedule = "8 */2 * * 1-5"
    retry_value = 0
else:
    execution_schedule = None
    retry_value = 0

def _load_dataset_names(config_filename, root_key):
    full_path = os.path.join(CONFIG_BASE_PATH, config_filename)
    with open(full_path) as f:
        data = json.load(f)
    return [dataset["table"] for dataset in data[root_key].values()]


def extract_telcustomer_datasets():
    return _load_dataset_names(
        "TelTools_SQLServer_TELCUSTOMER-Adhoc_Extract.json",
        "TELCUSTOMER-Adhoc",
    )


@dag(
    start_date=datetime(2025, 9, 2, tz="America/Chicago"),
    schedule=execution_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["TEH_PURCHASE_ORDER_CHANGE_ORDER"],
)
def DRIVER_TEH_PURCHASE_ORDER_CHANGE_ORDER(dbt_folder, domainGuid):


    TEH_PURCHASE_ORDER_CHANGE_ORDER_DBT = create_dbt_task(
        **{
            "Base_directory": os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id": "TEH_PURCHASE_ORDER_CHANGE_ORDER_DBT",
        }
    )

    TEH_PURCHASE_ORDER_CHANGE_ORDER_ATLAN_UPLOAD = TriggerDagRunOperator(
        task_id="TEH_PURCHASE_ORDER_CHANGE_ORDER_ATLAN_UPLOAD",
        trigger_dag_id="SYSTEM_UPDATE_ATLAN",
        conf={"domainGuid": domainGuid},
        wait_for_completion=True,
    )

    @task(
        map_index_template="{{ EXTRACT_TEH_PURCHASE_ORDER_CHANGE_ORDER }}",
        max_active_tis_per_dag=5,
    )
    def EXTRACT_TEH_PURCHASE_ORDER_CHANGE_ORDER(file_path, table_name):
        context = get_current_context()
        context["EXTRACT_TEH_PURCHASE_ORDER_CHANGE_ORDER"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_TEH_PURCHASE_ORDER_CHANGE_ORDER")
        tts.main(file_path, table_name)
        logger.info("Completed EXTRACT_TEH_PURCHASE_ORDER_CHANGE_ORDER")

    EXTRACT_TEH_PURCHASE_ORDER_CHANGE_ORDER_TASK = EXTRACT_TEH_PURCHASE_ORDER_CHANGE_ORDER.partial(
        file_path=os.path.join(CONFIG_BASE_PATH, "TelTools_SQLServer_TELCUSTOMER-Adhoc_Extract.json")
    ).expand(
        table_name=extract_telcustomer_datasets()
    )

    EXTRACT_TEH_PURCHASE_ORDER_CHANGE_ORDER_TASK >> TEH_PURCHASE_ORDER_CHANGE_ORDER_DBT >> TEH_PURCHASE_ORDER_CHANGE_ORDER_ATLAN_UPLOAD


DRIVER_TEH_PURCHASE_ORDER_CHANGE_ORDER(
    dbt_folder="+tag:teh_purchase_order_change_order",
    domainGuid="68b6288d-cf0e-4191-9130-b040d8414ebd",
)
