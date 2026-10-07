import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.bash import BashOperator
from include.Python.TELTools import update_atlan_domain

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    tags=["update_atlan"],
)
def SYSTEM_UPDATE_ATLAN(domainGuid):
    @task
    def UPDATE_ATLAN(domainGuid):
        logger.info("Started UPDATE_ATLAN")
        update_atlan_domain(domainGuid)
        logger.info("Completed UPDATE_ATLAN")
    
    UPDATE_ATLAN(domainGuid)

SYSTEM_UPDATE_ATLAN(domainGuid="584dc17b-59f0-45f7-ab13-e30a67c72da5")