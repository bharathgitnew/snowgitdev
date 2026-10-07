import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from include.Python.dbt_run_operator import create_dbt_task

import include.Python.getITHDFile as get_ithd
import include.Python.TelTools_SQLServer as tts
from include.Python.getMSGraphData import main as getMS

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    exectuion_schedule="30 7-22/3 * * *"
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
    tags=["ithd"],
)
def DRIVER_ITHD(previousRun,finalRun,entities):

    @task
    def EXTRACT_ITHD(previousRun,finalRun,entities):
        logger.info("Started EXTRACT_ITHD")
        get_ithd.main(previousRun,finalRun,entities)
        logger.info("Completed EXTRACT_ITHD")

    ITHD_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": "tag:ithd common.de_helpdesk --exclude pub.*",
            "task_id" : "ITHD_DBT"
        }
    )

    @task
    def EXTRACT_ITHD_SHAREPOINT():
        logger.info("Started SYSTEM_GET_MSGRAPH_DATA")
        getMS("get_list_items","FT_BY_NAME")
        logger.info("Completed SYSTEM_GET_MSGRAPH_DATA")

    [EXTRACT_ITHD(previousRun,finalRun,entities),EXTRACT_ITHD_SHAREPOINT()] >> ITHD_DBT

DRIVER_ITHD(previousRun="",finalRun="",entities=[])