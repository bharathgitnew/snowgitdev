import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from include.Python.getReleaseNotes import main as GRN
from include.Python.dbt_run_operator import create_dbt_task

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    exectuion_schedule="15 20 * * 4"
    retry_value=0
else:
    exectuion_schedule=None
    retry_value=0
@dag(
    start_date=datetime(2024, 9, 6, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["monday"],
)
def DRIVER_AZURE_DEVOPS():
    @task
    def EXTRACT_AZURE_DEVOPS():
        logger.info("Started EXTRACT_AZURE_DEVOPS")
        GRN()
        logger.info("Completed EXTRACT_AZURE_DEVOPS")

    AZURE_DEVOPS_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name":"tag:azure_devops common.azure_devpops --exclude pub.*",
            "task_id" : "AZURE_DEVOPS_DBT"
        }
    )

    EXTRACT_AZURE_DEVOPS()>> AZURE_DEVOPS_DBT

DRIVER_AZURE_DEVOPS()