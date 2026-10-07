import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

import include.Python.TelTools_SQLServer as tts

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    exectuion_schedule="05 1 * * *"
    retry_value=0
else:
    exectuion_schedule=None
    retry_value=0

def extract_table_names():
    with open('/usr/local/airflow/include/Configuration/TelTools_SQLServer_TELQS_Extract.json') as f:
        data=json.load(f)
    return [dataset["table"] for dataset in data["TELQS"].values()]

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["telqs"],
)
def DRIVER_TELQS():

    TELQS_DBT = TriggerDagRunOperator(
        task_id='TELQS_DBT',
        trigger_dag_id='DBT_EXECUTION',
        conf={"model_name": "tag:telqs --exclude pub.*"},
        wait_for_completion=True
        )

    @task(
        map_index_template="{{ telqs_map_index }}",
        max_active_tis_per_dag=4
    )
    def EXTRACT_TELQS(file_path, table_name):
        from airflow.operators.python import get_current_context

        context = get_current_context()
        context["telqs_map_index"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_TELQS")
        tts.main(file_path, table_name)
        logger.info("Completed EXTRACT_TELQS")

    EXTRACT_TABLES = EXTRACT_TELQS.partial(file_path='/usr/local/airflow/include/Configuration/TelTools_SQLServer_TELQS_Extract.json').expand(table_name=extract_table_names())

    EXTRACT_TABLES >> TELQS_DBT

DRIVER_TELQS()