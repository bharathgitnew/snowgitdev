import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from include.Python.ariba.Start_AribaProcess_2 import main as ajp
from include.Python.dbt_run_operator import create_dbt_task

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    exectuion_schedule_process="0 5 * * *"
    retry_value=0
else:
    exectuion_schedule_process=None
    retry_value=0

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"), 
    schedule=exectuion_schedule_process, 
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["ariba_process_2"],
)
def ARIBA_EXTRACT_PROCESS2(realm_name):
    @task
    def ARIBA_JOB_POSTINGS(realm_name):
        logger.info("Started ARIBA_JOB_POSTINGS")
        ajp(realm_name)
        logger.info("Completed ARIBA_JOB_POSTINGS")

    ARIBA_DBT = create_dbt_task(
            **{
                "Base_directory" : os.path.dirname(__file__),
                "model_name":"tag:ariba --exclude pub.*",
                "task_id" : "ARIBA_DBT"
            }
        )
    
    ARIBA_JOB_POSTINGS(realm_name) >> ARIBA_DBT

ARIBA_EXTRACT_PROCESS2(realm_name="tel-S4")