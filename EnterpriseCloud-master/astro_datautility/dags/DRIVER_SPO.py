import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from include.Python.dbt_run_operator import create_dbt_task

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    exectuion_schedule="1 0 * * *"
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
    tags=["spo"],
)
def DRIVER_SPO(resource_name1,resource_name2):

    EXTRACT_SPO_LIST_DATA = TriggerDagRunOperator(
                        task_id='EXTRACT_SPO_LIST_DATA',
                        trigger_dag_id='SYSTEM_GET_MSGRAPH_DATA',
                        conf={"resource_name":resource_name1},
                        wait_for_completion=True
                    )

    EXTRACT_SPO_FILES_DATA = TriggerDagRunOperator(
                        task_id='EXTRACT_SPO_FILES_DATA',
                        trigger_dag_id='SYSTEM_GET_SHAREPOINT_FILES',
                        conf={"job_name":resource_name2},
                        wait_for_completion=True
                    )

    SPO_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name":"tag:sharepoint --exclude pub.*",
            "task_id" : "SPO_DBT"
        }
    )

    [EXTRACT_SPO_LIST_DATA,EXTRACT_SPO_FILES_DATA] >> SPO_DBT

DRIVER_SPO("get_list_items","ALL")