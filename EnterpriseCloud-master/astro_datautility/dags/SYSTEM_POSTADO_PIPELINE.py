import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.bash import BashOperator
from include.Python.postADOPipelineRun import main as ado
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    tags=["pst_ado_pipeline"],
)
@task
def SYSTEM_POSTADO_PIPELINE(pipelineID,branch):
    logger.info("Started SYSTEM_POSTADO_PIPELINE")
    ado(pipelineID,branch)
    logger.info("Completed SYSTEM_POSTADO_PIPELINE")  

SYSTEM_POSTADO_PIPELINE(pipelineID="203", branch="qa")