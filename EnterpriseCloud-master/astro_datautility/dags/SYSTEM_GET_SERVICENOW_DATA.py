import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from include.Python.getServiceNowData import main as getSN

ASTRO_DEPLOYMENT_NAME = os.environ.get('ASTRO_DEPLOYMENT_NAME', 'DEV')

logger = logging.getLogger("airflow.task")

@dag(
    start_date=datetime(2026, 5, 1, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    tags=["ServiceNow"],
)
@task
def SYSTEM_GET_SERVICENOW_DATA(resource_name=None):
    logger.info("Started SYSTEM_GET_SERVICENOW_DATA")
    getSN(resource_name)
    logger.info("Completed SYSTEM_GET_SERVICENOW_DATA")

SYSTEM_GET_SERVICENOW_DATA(resource_name=None)
