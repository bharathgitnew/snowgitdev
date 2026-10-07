import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
import json
from airflow.operators.python import get_current_context
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from include.Python.getMobileIronData import main as MobileIronExtract
from include.Python.getKnowBe4Data import main as Knowbe4Extract
from include.Python.getCopyFile import main as PythonCopyFile
from include.Python.dbt_run_operator_new_platform import create_dbt_task, create_dbt_task_test

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']
logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    execution_schedule="25 7 * * *"
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
    tags=["teh_infosec"],
)
def DRIVER_TEH_INFOSEC(dbt_folder,domainGuid,config_copy_file):

    @task
    def TEH_INFOSEC_EXTRACT_MOBILEIRON_DATA():
        logger.info("Started TEH_INFOSEC_EXTRACT_MOBILEIRON_DATA")
        MobileIronExtract()
        logger.info("Completed TEH_INFOSEC_EXTRACT_MOBILEIRON_DATA")

    @task
    def TEH_INFOSEC_EXTRACT_KNOWBE4_DATA():
        logger.info("Started TEH_INFOSEC_EXTRACT_KNOWBE4_DATA")
        Knowbe4Extract()
        logger.info("Completed TEH_INFOSEC_EXTRACT_KNOWBE4_DATA")

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
        max_active_tis_per_dag=11
    )
    def COPY_FILE(config_path, section):
        context = get_current_context()
        context["map_index_copy_file"] = "Extract: " + str(section)
        logger.info(f"Started Copy FIle Section {str(section)}")
        PythonCopyFile(config_path, section)
        logger.info(f"Completed Copy FIle Section {str(section)}")



    TEH_INFOSEC_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEH_INFOSEC_DBT"
        }        
    )

    TEH_INFOSEC_TESTS = create_dbt_task_test(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TEH_INFOSEC_TESTS"
        }          
    )
    
    # TEH_INFOSEC_ATLAN_UPLOAD =   TriggerDagRunOperator(
    #     task_id='TEH_INFOSEC_ATLAN_UPLOAD',
    #     trigger_dag_id='SYSTEM_UPDATE_ATLAN',
    #     conf={"domainGuid": domainGuid},
    #     wait_for_completion=True
    #     )
    
    # [TEH_INFOSEC_EXTRACT_MOBILEIRON_DATA(),TEH_INFOSEC_EXTRACT_KNOWBE4_DATA()] >> TEH_INFOSEC_DBT >> TEH_INFOSEC_TESTS >> TEH_INFOSEC_ATLAN_UPLOAD
    [TEH_INFOSEC_EXTRACT_MOBILEIRON_DATA(),TEH_INFOSEC_EXTRACT_KNOWBE4_DATA(),COPY_FILE.expand_kwargs(COPY_CONFIGS) ] >> TEH_INFOSEC_DBT >> TEH_INFOSEC_TESTS


DRIVER_TEH_INFOSEC(dbt_folder="teh_infosec",domainGuid="d81ced77-1b65-4a0c-ba88-cdfa69f9f701",
                   config_copy_file ="/usr/local/airflow/include/Configuration/TelTools_CopyFile_InfoSec.json" )