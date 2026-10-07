import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.bash import BashOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from include.Python.dbt_run_operator_new_platform import create_dbt_task, create_dbt_task_test
import include.Python.TelTools_SQLServer as tts

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    execution_schedule="30 4 * * *"
    retry_value=0
else:
    execution_schedule=None
    retry_value=0

def extract_table_names():
    with open('/usr/local/airflow/include/Configuration/TelTools_SQLServer_TELCUSTOMER-DIVERSESYSTEMS_Extract.json') as f:
        data=json.load(f)
    return [dataset["table"] for dataset in data["TELCUSTOMER-DIVERSESYSTEMS"].values()]

@dag(
    start_date=datetime(2025, 9, 18, tz="America/Chicago"),
    schedule=execution_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["TELCUSTOMER-DIVERSESYSTEMS"],
)
def DRIVER_TEA_DIVERSE_SYSTEMS():

    # TEA_DIVERSE_SYSTEMS_DBT = TriggerDagRunOperator(
    #     task_id='TEA_DIVERSE_SYSTEMS_DBT',
    #     trigger_dag_id='DBT_EXECUTION_NEW_PLATFORM',
    #     conf={"model_name": "tea_diverse_systems_and_solutions"},
    #     wait_for_completion=True
    #     )

    TEA_DIVERSE_SYSTEMS_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": 'tea_diverse_systems_and_solutions',
            "task_id" : "TEA_DIVERSE_SYSTEMS_DBT"
        }        
    )

    @task(
        map_index_template="{{ TEA_DIVERSE_SYSTEMS_MAP_INDEX }}"
    )
    def EXTRACT_TEA_DIVERSE_SYSTEMS(file_path, table_name):
        from airflow.operators.python import get_current_context

        context = get_current_context()
        context["TEA_DIVERSE_SYSTEMS_MAP_INDEX"] = "Extract: " + str(table_name)
        logger.info("Started EXTRACT_TEA_DIVERSE_SYSTEMS")
        tts.main(file_path, table_name)
        logger.info("Completed EXTRACT_TEA_DIVERSE_SYSTEMS")

    EXTRACT_TABLES = EXTRACT_TEA_DIVERSE_SYSTEMS.partial(file_path='/usr/local/airflow/include/Configuration/TelTools_SQLServer_TELCUSTOMER-DIVERSESYSTEMS_Extract.json').expand(table_name=extract_table_names())

    EXTRACT_TABLES >> TEA_DIVERSE_SYSTEMS_DBT

DRIVER_TEA_DIVERSE_SYSTEMS()