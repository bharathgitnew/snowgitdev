import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from include.Python.getSFTPFile import main as SambaFileShare
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from include.Python.getCopyFile import main as PythonCopyFile
from airflow.operators.python import PythonOperator, get_current_context
from include.Python.dbt_run_operator_new_platform import create_dbt_task, create_dbt_task_test

ASTRO_DEPLOYMENT_NAME = os.environ["ASTRO_DEPLOYMENT_NAME"]
logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME == "PROD":
    execution_schedule = "00 05 * * *"
    retry_value = 0
else:
    execution_schedule = None
    retry_value = 0

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=execution_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["teh_human_resources"],
)
def DRIVER_TEH_HUMAN_RESOURCES(config_copy_file,dbt_folder,domainGuid):

    # WORKDAY_ATTENDANCE_EXTRACT = TriggerDagRunOperator(
    #     task_id="WORKDAY_ATTENDANCE_EXTRACT",
    #     trigger_dag_id="SYSTEM_GET_SFTP_FILES",
    #     conf={
    #         "config_path": "/usr/local/airflow/include/Configuration/TelTools_SFTPFile.json",
    #         "section": "TEL_Workday_USA-Attendance_Status",
    #     },
    #     wait_for_completion=True,
    # )

    # WORKDAY_CAMPAIGN_EXTRACT = TriggerDagRunOperator(
    #     task_id="WORKDAY_CAMPAIGN_EXTRACT",
    #     trigger_dag_id="SYSTEM_GET_SFTP_FILES",
    #     conf={
    #         "config_path": "/usr/local/airflow/include/Configuration/TelTools_SFTPFile.json",
    #         "section": "TEL_Workday_USA-Campaign",
    #     },
    #     wait_for_completion=True,
    # )

    WORKDAY_ATTENDANCE_EXTRACT = PythonOperator(
        task_id="WORKDAY_ATTENDANCE_EXTRACT",
        python_callable=SambaFileShare,
        op_kwargs={
            "config_file": "/usr/local/airflow/include/Configuration/TelTools_SFTPFile.json",
            "section": "TEL_Workday_USA-Attendance_Status",
        },
    )

    WORKDAY_CAMPAIGN_EXTRACT = PythonOperator(
        task_id="WORKDAY_CAMPAIGN_EXTRACT",
        python_callable=SambaFileShare, 
        op_kwargs={
            "config_file": "/usr/local/airflow/include/Configuration/TelTools_SFTPFile.json",
            "section": "TEL_Workday_USA-Campaign",
        },
    )

    # TEH_HUMAN_RESOURCES_DBT = TriggerDagRunOperator(
    #     task_id='TEH_HUMAN_RESOURCES_DBT',
    #     trigger_dag_id='DBT_EXECUTION_NEW_PLATFORM',
    #     conf={"model_name": dbt_folder},
    #     wait_for_completion=True
    # )

    # TEH_HUMAN_RESOURCES_TESTS = TriggerDagRunOperator(
    #     task_id='TEH_HUMAN_RESOURCES_TESTS',
    #     trigger_dag_id='DBT_TEST_NEW_PLATFORM',
    #     conf={"model_name": dbt_folder},
    #     wait_for_completion=True
    # )

    TEH_HUMAN_RESOURCES_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEH_HUMAN_RESOURCES_DBT"
        }        
    )

    TEH_HUMAN_RESOURCES_TESTS = create_dbt_task_test(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEH_HUMAN_RESOURCES_TESTS"
        }          
    )
    
    @task
    def BUILD_COPY_CONFS(config_copy_file) :
        with open(config_copy_file, 'r') as file:
            data=json.load(file)

        return [
            {
                "config_path": config_copy_file,
                "section": table
            } 
            for table in [
                dataset_key for dataset_key, _ in data["CopyFile"].items()
            ]
        ]

    COPY_CONFIGS = BUILD_COPY_CONFS(config_copy_file)

    @task(
        map_index_template="{{ map_index_copy_file }}",
        max_active_tis_per_dag=1
    )
    def WORKDAY_COPY_FILE(config_path, section):
        context = get_current_context()
        context["map_index_copy_file"] = "Extract: " + str(section)
        logger.info(f"Started Copy FIle Section {str(section)}")
        PythonCopyFile(config_path, section)
        logger.info(f"Completed Copy FIle Section {str(section)}")

    
    TEH_HR_ATLAN_UPLOAD = TriggerDagRunOperator(
        task_id='TMEA_SAFETY_ATLAN_UPLOAD',
        trigger_dag_id='SYSTEM_UPDATE_ATLAN',
        conf={"domainGuid": domainGuid},
        wait_for_completion=True
    )
    
    [WORKDAY_ATTENDANCE_EXTRACT, WORKDAY_CAMPAIGN_EXTRACT, WORKDAY_COPY_FILE.expand_kwargs(COPY_CONFIGS)] >> TEH_HUMAN_RESOURCES_DBT >> TEH_HUMAN_RESOURCES_TESTS >> TEH_HR_ATLAN_UPLOAD
    

DRIVER_TEH_HUMAN_RESOURCES(
    config_copy_file="/usr/local/airflow/include/Configuration/TelTools_CopyFile_Workday.json",
    dbt_folder="teh_human_resources",
    domainGuid="5610e1c1-b80c-43f4-b727-c4db7e0ef25d"
)

