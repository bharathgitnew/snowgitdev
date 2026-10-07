import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from include.Python.getKanbanize import main as PythongetKB
from airflow.operators.python import PythonOperator
from include.Python.dbt_run_operator_new_platform import create_dbt_task, create_dbt_task_test

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']
logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    execution_schedule="45 7-17/2 * * 1-5"
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
    tags=["teh_data_ops"],
)
def DRIVER_TEH_DATA_OPS(dbt_folder,domainGuid):

    TEH_DATA_OPS_EXTRACT_ATLAN = TriggerDagRunOperator(
        task_id='TEH_DATA_OPS_EXTRACT_ATLAN',
        trigger_dag_id='SYSTEM_GET_ATLAN_DATA',
        conf={"table_name":None, "full_refresh":False},
        wait_for_completion=True
        )

    # TEH_DATA_OPS_EXTRACT_KANBAN = TriggerDagRunOperator(
    #     task_id='TEH_DATA_OPS_EXTRACT_KANBAN',
    #     trigger_dag_id='SYSTEM_GET_KANBANIZE_DATA',
    #     wait_for_completion=True
    #     )

    # TEH_DATA_OPS_DBT = TriggerDagRunOperator(
    #     task_id='TEH_DATA_OPS_DBT',
    #     trigger_dag_id='DBT_EXECUTION_NEW_PLATFORM',
    #     conf={"model_name": dbt_folder},
    #     wait_for_completion=True
    #     )

    # TEH_DATA_OPS_TESTS = TriggerDagRunOperator(
    #     task_id='TEH_DATA_OPS_TESTS',
    #     trigger_dag_id='DBT_TEST_NEW_PLATFORM',
    #     conf={"model_name": dbt_folder},
    #     wait_for_completion=True
    #     )

    TEH_DATA_OPS_EXTRACT_KANBAN = PythonOperator(
        task_id="TEH_DATA_OPS_EXTRACT_KANBAN",
        python_callable=PythongetKB,
    )

    TEH_DATA_OPS_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEH_DATA_OPS_DBT"
        }        
    )

    TEH_DATA_OPS_TESTS = create_dbt_task_test(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEH_DATA_OPS_TESTS"
        }          
    )

    TEH_DATA_OPS_ATLAN_UPLOAD = TriggerDagRunOperator(
        task_id='TEH_DATA_OPS_ATLAN_UPLOAD',
        trigger_dag_id='SYSTEM_UPDATE_ATLAN',
        conf={"domainGuid": domainGuid},
        wait_for_completion=True
    )

    [TEH_DATA_OPS_EXTRACT_KANBAN,TEH_DATA_OPS_EXTRACT_ATLAN] >> TEH_DATA_OPS_DBT >> TEH_DATA_OPS_TESTS >> TEH_DATA_OPS_ATLAN_UPLOAD

DRIVER_TEH_DATA_OPS(dbt_folder="teh_data_ops",domainGuid="b7b5bf67-0fa2-4ecb-ab7d-c3df9be91b29")