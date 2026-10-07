import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
import include.Python.getSirfisData as Sirfis
from include.Python.getMSGraphData import main as getMS

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    exectuion_schedule="0 4,12 * * 1-5"
    retry_value=0
else:
    exectuion_schedule=None
    retry_value=0
@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["sirfis"],
)
def DRIVER_SIRFIS():
    @task
    def EXTRACT_SIRFIS_DATA():
        logger.info("Started EXTRACT_SIRFIS_DATA")
        Sirfis.main()
        logger.info("Completed EXTRACT_SIRFIS_DATA")

    @task
    def EXTRACT_SHAREPOINT_DATA():
        logger.info("Started SYSTEM_GET_MSGRAPH_DATA")
        getMS("get_list_items","BUSINESS_UNIT_LOOKUP")
        logger.info("Completed SYSTEM_GET_MSGRAPH_DATA")
    
    EXTRACT_SIRFIS_DATA() >> EXTRACT_SHAREPOINT_DATA()

DRIVER_SIRFIS()