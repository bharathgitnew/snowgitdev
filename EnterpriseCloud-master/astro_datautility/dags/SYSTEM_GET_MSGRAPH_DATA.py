import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.bash import BashOperator
from include.Python.getMSGraphData import main as getMS
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    tags=["get_MSGraph"],
)
@task
def SYSTEM_GET_MSGRAPH_DATA(resource_name,specific_resource):
    logger.info("Started SYSTEM_GET_MSGRAPH_DATA")
    getMS(resource_name,specific_resource)
    logger.info("Completed SYSTEM_GET_MSGRAPH_DATA")

SYSTEM_GET_MSGRAPH_DATA(resource_name=None,specific_resource=None)