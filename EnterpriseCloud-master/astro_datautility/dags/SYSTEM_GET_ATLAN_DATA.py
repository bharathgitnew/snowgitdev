import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.bash import BashOperator
from include.Python.getAtlan import get_asset_data
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    tags=["get_atlan"],
)
@task
def SYSTEM_GET_ATLAN_DATA(table_name,full_refresh):
    logger.info("Started SYSTEM_GET_ATLAN_DATA")
    get_asset_data(table_name,full_refresh)
    logger.info("Completed SYSTEM_GET_ATLAN_DATA")

SYSTEM_GET_ATLAN_DATA(table_name=None, full_refresh=False)