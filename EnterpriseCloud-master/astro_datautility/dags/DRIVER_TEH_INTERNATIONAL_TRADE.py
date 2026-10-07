import os
import logging
from airflow.decorators import dag, task, task_group
from pendulum import datetime
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.providers.standard.operators.empty import EmptyOperator
from include.Python.dbt_run_operator_new_platform import create_dbt_task, create_dbt_task_test
from include.Python.getSharePointFile import main as sharepoint_files

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']
logger = logging.getLogger("airflow.task")


if ASTRO_DEPLOYMENT_NAME=='PROD':
    execution_schedule="0 15 * * *"
    retry_value=0
else:
    execution_schedule=None
    retry_value=0

@task_group(group_id='GET_SHAREPOINT_FILES')
def get_sharepoint_files():
    @task
    def run_sharepoint_job(job_name):
        sharepoint_files(job_name)

    t1 = run_sharepoint_job.override(task_id="TEA_Orders")('TEA Orders')
    t2 = run_sharepoint_job.override(task_id="TMEA_Export_Shipment_History_Snowflake_update")('TMEA_Export_Shipment_History_Snowflake_update')
    t3 = run_sharepoint_job.override(task_id="TMEA_Machine_Export_Pricing")('TMEA_Machine_Export_Pricing')
    t4 = run_sharepoint_job.override(task_id="Date_2_Code_sheets")('Date_2_Code_sheets')
    t5 = run_sharepoint_job.override(task_id="Weekly_Allocations")('Weekly_Allocations')        
    x = EmptyOperator(task_id="wait_for_sharepoint_files")
    [t1, t2, t3, t4, t5] >> x

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=execution_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["teh_international_trade"],
)
def DRIVER_TEH_INTERNATIONAL_TRADE(dbt_folder,domainGuid):

    TEH_INTERNATIONAL_TRADE_UPS_EXTRACT = TriggerDagRunOperator(
        task_id='TEH_INTERNATIONAL_TRADE_UPS_EXTRACT',
        trigger_dag_id='SYSTEM_GET_SFTP_FILES',
        conf={"config_path":"/usr/local/airflow/include/Configuration/TelTools_SFTPFile.json", "section":"TEA_SEC_232_Daily_Report"},
        wait_for_completion=True
        )

    TEH_INTERNATIONAL_TRADE_ALL_PARTS_EXTRACT = TriggerDagRunOperator(
        task_id='TEH_INTERNATIONAL_TRADE_ALL_PARTS_EXTRACT',
        trigger_dag_id='SYSTEM_GET_BOX_FILES',
        conf={"config_path":"/usr/local/airflow/include/Configuration/TelTools_getBoxFile_UPS.json"},
        wait_for_completion=True
        )
    
    # TEH_INTERNATIONAL_TRADE_DBT = TriggerDagRunOperator(
    #     task_id='TEH_INTERNATIONAL_TRADE_DBT',
    #     trigger_dag_id='DBT_EXECUTION_NEW_PLATFORM',
    #     conf={"model_name": dbt_folder},
    #     wait_for_completion=True
    #     )

    # TEH_INTERNATIONAL_TRADE_TESTS = TriggerDagRunOperator(
    #     task_id='TEH_INTERNATIONAL_TRADE_TESTS',
    #     trigger_dag_id='DBT_TEST_NEW_PLATFORM',
    #     conf={"model_name": dbt_folder},
    #     wait_for_completion=True
    #     )

    TEH_INTERNATIONAL_TRADE_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEH_INTERNATIONAL_TRADE_DBT"
        }        
    )

    TEH_INTERNATIONAL_TRADE_TESTS = create_dbt_task_test(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEH_INTERNATIONAL_TRADE_TESTS"
        }          
    )

    TEH_INTERNATIONAL_TRADE_ATLAN_UPLOAD = TriggerDagRunOperator(
        task_id='TEH_INTERNATIONAL_TRADE_ATLAN_UPLOAD',
        trigger_dag_id='SYSTEM_UPDATE_ATLAN',
        conf={"domainGuid": domainGuid},
        wait_for_completion=True
    )

    [TEH_INTERNATIONAL_TRADE_UPS_EXTRACT,TEH_INTERNATIONAL_TRADE_ALL_PARTS_EXTRACT, get_sharepoint_files()] >> TEH_INTERNATIONAL_TRADE_DBT >> TEH_INTERNATIONAL_TRADE_TESTS >> TEH_INTERNATIONAL_TRADE_ATLAN_UPLOAD


DRIVER_TEH_INTERNATIONAL_TRADE(dbt_folder="teh_international_trade",domainGuid="fce51fb2-4b14-4a14-b079-2c297db085e4")