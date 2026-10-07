import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from include.Python.dbt_run_operator import create_dbt_task
import include.Python.getPowerBILogs as getPBI

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']
logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    exectuion_schedule="15 1 * * *"
    retry_value=3
else:
    exectuion_schedule=None
    retry_value=0
@dag(
    start_date=datetime(2024, 9, 6, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["powerbi"],
)
def DRIVER_POWERBI(view_name):
    @task
    def EXTRACT_POWERBI_DATA(view_name):
        logger.info("Started EXTRACT_POWERBI_DATA")
        getPBI.main(view_name)
        logger.info("Completed EXTRACT_POWERBI_DATA")
    
    POWERBI_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name":"tag:powerbi --exclude pub.*",
            "task_id" : "POWERBI_DBT"
        }
    )

    EXTRACT_POWERBI_DATA(view_name) >> POWERBI_DBT

DRIVER_POWERBI(view_name="ALL")