import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from include.Python.getCRMFile import main as PythonCrmFile
from airflow.operators.python import PythonOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from include.Python.dbt_run_operator_new_platform import create_dbt_task, create_dbt_task_test
from include.Python.dbt_run_operator import create_dbt_task as create_dbt_task_old_platform

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']
logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    execution_schedule="10 1-23/2 * * *"
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
    tags=["teh_equipment_sales"],
)
def DRIVER_TEH_EQUIPMENT_SALES(dbt_folder,domainGuid):

    TEH_EQUIPMENT_SALES_CRM_EXTRACT = PythonOperator(
        task_id="TEH_EQUIPMENT_SALES_CRM_EXTRACT",
        python_callable=PythonCrmFile,
        op_kwargs={
            "srcAccount":'PROD1',
            "previousRun":"",
            "finalRun":"", 
            "entities":[]
        },
    )

    TEH_EQUIPMENT_SALES_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEH_EQUIPMENT_SALES_DBT"
        }        
    )

    TEH_EQUIPMENT_SALES_OLD_DBT = create_dbt_task_old_platform(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": "tag:crm_file tag:crm common.de_sales_operations common.de_tee_sales_service_admin --exclude pub.*",
            "task_id" : "TEH_EQUIPMENT_SALES_OLD_DBT"
        }        
    )

    TEH_EQUIPMENT_SALES_TESTS = create_dbt_task_test(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEH_EQUIPMENT_SALES_TESTS"
        }          
    )

    # TEH_EQUIPMENT_SALES_DBT = TriggerDagRunOperator(
    #     task_id='TEH_EQUIPMENT_SALES_DBT',
    #     trigger_dag_id='DBT_EXECUTION_NEW_PLATFORM',
    #     conf={"model_name": dbt_folder},
    #     wait_for_completion=True
    # )

    # TEH_EQUIPMENT_SALES_OLD_DBT = TriggerDagRunOperator(
    #     task_id='TEH_EQUIPMENT_SALES_OLD_DBT',
    #     trigger_dag_id='DBT_EXECUTION',
    #     conf={"model_name": "tag:crm_file tag:crm common.de_sales_operations common.de_tee_sales_service_admin --exclude pub.*"},
    #     wait_for_completion=True
    # )

    # TEH_EQUIPMENT_SALES_TESTS = TriggerDagRunOperator(
    #     task_id='TEH_EQUIPMENT_SALES_TESTS',
    #     trigger_dag_id='DBT_TEST_NEW_PLATFORM',
    #     conf={"model_name": dbt_folder},
    #     wait_for_completion=True
    # )

    TEH_EQUIPMENT_SALES_ATLAN_UPLOAD = TriggerDagRunOperator(
        task_id='TEH_EQUIPMENT_SALES_ATLAN_UPLOAD',
        trigger_dag_id='SYSTEM_UPDATE_ATLAN',
        conf={"domainGuid": domainGuid},
        wait_for_completion=True
    )

    TEH_EQUIPMENT_SALES_CRM_EXTRACT >> [TEH_EQUIPMENT_SALES_DBT,TEH_EQUIPMENT_SALES_OLD_DBT] >> TEH_EQUIPMENT_SALES_TESTS >> TEH_EQUIPMENT_SALES_ATLAN_UPLOAD

DRIVER_TEH_EQUIPMENT_SALES(dbt_folder="teh_equipment_sales",domainGuid="a23f3a29-caf7-48ca-8e90-35d6462d9ffc")