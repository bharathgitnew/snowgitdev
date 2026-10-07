import os
from airflow.decorators import dag, task
from pendulum import datetime
import include.Python.getMondayDotCom as GMD

ASTRO_DEPLOYMENT_NAME = os.environ.get('ASTRO_DEPLOYMENT_NAME', 'DEV')

if ASTRO_DEPLOYMENT_NAME == 'PROD':
    execution_schedule = "30 5 * * *"
    retry_value = 0
else:
    execution_schedule = None
    retry_value = 0


@dag(
    start_date=datetime(2024, 9, 6, tz="America/Chicago"),
    schedule=execution_schedule,
    catchup=False,
    default_args={"retries": retry_value},
    tags=["monday"],
)
def DRIVER_MONDAY(boards="", full_load="false"):
    @task
    def EXTRACT_MONDAY_DATA(boards, full_load):
        print("Started EXTRACT_MONDAY_DATA")
        boards_param = boards if boards else None
        full_load_param = full_load.lower() == "true"
        if boards_param:
            print(f"Processing specific boards: {boards_param}")
        if full_load_param:
            print("Running in FULL LOAD mode")
        result = GMD.run_ingestion(boards=boards_param, full_load=full_load_param)
        print(f"Completed EXTRACT_MONDAY_DATA - {result['total_records']} records loaded")
        return result

    EXTRACT_MONDAY_DATA(boards, full_load)


DRIVER_MONDAY(boards="", full_load="false")