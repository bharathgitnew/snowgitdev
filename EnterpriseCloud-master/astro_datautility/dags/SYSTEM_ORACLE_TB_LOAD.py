import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.bash import BashOperator
from include.Python.oracle_tb_load import main as tb_load
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    tags=["oracle_tb_load"],
)
@task
def SYSTEM_ORACLE_TB_LOAD(company_name, fiscal_month, fiscal_year, env, wbs_blank='Y'):
    logger.info("Started SYSTEM_ORACLE_TB_LOAD")
    tb_load(company_name, fiscal_month, fiscal_year, env, wbs_blank)
    logger.info("Completed SYSTEM_ORACLE_TB_LOAD")

SYSTEM_ORACLE_TB_LOAD(company_name = 'TTCA', 
                      fiscal_month = '08', 
                      fiscal_year = '2026', 
                      env = 'TEST', 
                      wbs_blank='Y')