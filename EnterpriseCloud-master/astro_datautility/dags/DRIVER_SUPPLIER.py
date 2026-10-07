import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from include.Python.dbt_run_operator import create_dbt_task
import include.Python.TelTools_SQLServer as tts


ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    exectuion_schedule="0 3,12 * * *"
    retry_value=3
else:
    exectuion_schedule=None
    retry_value=0

def extract_table_names():
    with open('/usr/local/airflow/include/Configuration/TelTools_SQLServer_SUPPLIER_Extract.json') as f:
        data=json.load(f)
    return [dataset["table"] for dataset in data["SUPPLIER"].values()]

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["supplier"],
)
def DRIVER_SUPPLIER():
    
    SUPPLIER_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name":"tag:supplier --exclude pub.*",
            "task_id" : "SUPPLIER_DBT"
        }
    )

    @task(
        map_index_template="{{ SUPPLIER_CUSTOM_MAP_INDEX }}",
        max_active_tis_per_dag=3
    )
    def EXTRACT_SUPPLIER(file_path, table_name):
        from airflow.operators.python import get_current_context

        context = get_current_context()
        context["SUPPLIER_CUSTOM_MAP_INDEX"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_SUPPLIER")
        tts.main(file_path, table_name)
        logger.info("Completed EXTRACT_SUPPLIER")

    EXTRACT_TABLES = EXTRACT_SUPPLIER.partial(file_path='/usr/local/airflow/include/Configuration/TelTools_SQLServer_SUPPLIER_Extract.json').expand(table_name=extract_table_names())

    EXTRACT_TABLES >> SUPPLIER_DBT

DRIVER_SUPPLIER()