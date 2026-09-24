import os
import logging
from airflow.decorators import dag
from airflow.providers.databricks.operators.databricks import DatabricksSubmitRunOperator
from pendulum import datetime

ASTRO_DEPLOYMENT_NAME = os.environ["ASTRO_DEPLOYMENT_NAME"]

logger = logging.getLogger("airflow.task")

DATABRICKS_CONN_ID = "databricks_default"
# Workspace path to the script that used to be imported as
# include.Python.ariba.Start_AribaProcess_1; it now runs on the Databricks
# cluster and must accept realm_name as sys.argv[1] instead of a function call.
ARIBA_PYTHON_FILE = "/Workspace/Repos/ariba/include/Python/ariba/Start_AribaProcess_1.py"

if ASTRO_DEPLOYMENT_NAME == "PROD":
    exectuion_schedule_process = "0 4 * * *"
    retry_value = 0
    databricks_new_cluster = {
        "spark_version": "14.3.x-scala2.12",
        "node_type_id": "Standard_DS3_v2",
        "num_workers": 2,
    }
else:
    exectuion_schedule_process = None
    retry_value = 0
    databricks_new_cluster = {
        "spark_version": "14.3.x-scala2.12",
        "node_type_id": "Standard_DS3_v2",
        "num_workers": 1,
    }


@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=exectuion_schedule_process,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["ariba_process_1", "databricks"],
)
def ARIBA_EXTRACT_PROCESS1(realm_name):
    ARIBA_JOB_POSTINGS = DatabricksSubmitRunOperator(
        task_id="ARIBA_JOB_POSTINGS",
        databricks_conn_id=DATABRICKS_CONN_ID,
        new_cluster=databricks_new_cluster,
        spark_python_task={
            "python_file": ARIBA_PYTHON_FILE,
            "parameters": [realm_name],
        },
    )
    ARIBA_JOB_POSTINGS


ARIBA_EXTRACT_PROCESS1(realm_name="tel-S4")
