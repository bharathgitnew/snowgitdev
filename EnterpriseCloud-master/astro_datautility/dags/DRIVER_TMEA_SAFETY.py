import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from include.Python.dbt_run_operator_new_platform import create_dbt_task, create_dbt_task_test

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']
logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    execution_schedule="55 5 * * *"
    retry_value=0
else:
    execution_schedule=None
    retry_value=0
@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=execution_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["tmea_safety"],
)
def DRIVER_TMEA_SAFETY(dbt_folder,domainGuid):

    # TMEA_SAFETY_DBT = TriggerDagRunOperator(
    #     task_id='TMEA_SAFETY_DBT',
    #     trigger_dag_id='DBT_EXECUTION_NEW_PLATFORM',
    #     conf={"model_name": dbt_folder},
    #     wait_for_completion=True
    #     )

    # TMEA_SAFETY_TESTS = TriggerDagRunOperator(
    #     task_id='TMEA_SAFETY_TESTS',
    #     trigger_dag_id='DBT_TEST_NEW_PLATFORM',
    #     conf={"model_name": dbt_folder},
    #     wait_for_completion=True
    #     )

    TMEA_SAFETY_ATLAN_UPLOAD = TriggerDagRunOperator(
        task_id='TMEA_SAFETY_ATLAN_UPLOAD',
        trigger_dag_id='SYSTEM_UPDATE_ATLAN',
        conf={"domainGuid": domainGuid},
        wait_for_completion=True
    )

    # One independent dbt run >> test chain per platform; the chains run in parallel
    for platform in ("snowflake", "databricks"):
        dbt_run = create_dbt_task(
            **{
                "Base_directory" : os.path.dirname(__file__),
                "model_name": dbt_folder,
                "task_id" : f"TMEA_SAFETY_DBT_{platform.upper()}",
                "platform": platform
            }
        )

        dbt_test = create_dbt_task_test(
            **{
                "Base_directory" : os.path.dirname(__file__),
                "model_name": dbt_folder,
                "task_id" : f"TMEA_SAFETY_TESTS_{platform.upper()}",
                "platform": platform
            }
        )

        dbt_run >> dbt_test >> TMEA_SAFETY_ATLAN_UPLOAD

DRIVER_TMEA_SAFETY(dbt_folder="tmea_safety",domainGuid="2cabebc5-5cf3-4045-af03-bc5b2422a808")