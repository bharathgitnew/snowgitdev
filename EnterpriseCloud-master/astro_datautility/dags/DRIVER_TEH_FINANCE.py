import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from include.Python.getSapData import main as GetSAPData
from airflow.operators.python import PythonOperator
from include.Python.dbt_run_operator_new_platform import create_dbt_task, create_dbt_task_test

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    exectuion_schedule= None # this now runs on mini directly after finance extraction
    # exectuion_schedule= "0 4,12,17,21 * * *"
    retry_value=3
else:
    exectuion_schedule=None
    retry_value=0

@dag(
    start_date=datetime(2025, 9, 2, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["teh_finance"],
)
def DRIVER_TEH_FINANCE(section,record_limit,use_replay_queue,archive_file,extract_type,domainGuid):

    # FINANCE_EXTRACT = TriggerDagRunOperator(
    #         task_id='TEH_FINANCE_EXTRACT',
    #         trigger_dag_id='SYSTEM_GET_SAP_DATA',
    #         conf={"section":section,"record_limit":record_limit,"use_replay_queue":use_replay_queue,"archive_file":archive_file,"extract_type":extract_type,},
    #         wait_for_completion=True
    #     )

    # FINANCE_EXTRACT = PythonOperator(
    #     task_id="TEH_FINANCE_EXTRACT",
    #     python_callable=GetSAPData,
    #     op_kwargs={
    #         "section":section,
    #         "record_limit":record_limit,
    #         "use_replay_queue":use_replay_queue,
    #         "archive_file":archive_file,
    #         "extract_type":extract_type,
    #     },
    # )

    # FINANCE_DBT = TriggerDagRunOperator(
    #     task_id='TEH_FINANCE_DBT',
    #     trigger_dag_id='DBT_EXECUTION_NEW_PLATFORM',
    #     conf={"model_name": "tag:finance"},
    #     wait_for_completion=True
    #     )

    FINANCE_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": "teh_finance",
            "task_id" : "TEH_FINANCE_DBT"
        }
    )

    # FINANCE_DBT_TEST = TriggerDagRunOperator(
    #     task_id='TEH_FINANCE_DBT_TEST',
    #     trigger_dag_id='DBT_TEST_NEW_PLATFORM',
    #     conf={"model_name": "tag:finance"},
    #     wait_for_completion=True
    #     )

    FINANCE_DBT_TEST = create_dbt_task_test(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": "teh_finance",
            "task_id" : "TEH_FINANCE_DBT_TEST"
        }
    )

    FINANCE_ATLAN_UPLOAD = TriggerDagRunOperator(
        task_id='TEH_FINANCE_ATLAN_UPLOAD',
        trigger_dag_id='SYSTEM_UPDATE_ATLAN',
        conf={"domainGuid": domainGuid},
        wait_for_completion=True
    )

    # FINANCE_EXTRACT >> FINANCE_DBT >> FINANCE_DBT_TEST >> FINANCE_ATLAN_UPLOAD
    FINANCE_DBT >> FINANCE_DBT_TEST >> FINANCE_ATLAN_UPLOAD

DRIVER_TEH_FINANCE(section="ALL",record_limit="NotTrue",use_replay_queue="NotTrue",archive_file="false",extract_type="finance",domainGuid="3c298dfe-4c51-4745-92e0-145bf1e304d0")