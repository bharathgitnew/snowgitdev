import os
from airflow.decorators import dag, task
from pendulum import datetime
import include.Python.getOutlookAttachment as GOA


ASTRO_DEPLOYMENT_NAME = os.environ.get('ASTRO_DEPLOYMENT_NAME', 'DEV')

if ASTRO_DEPLOYMENT_NAME == 'PROD':
    execution_schedule = "0 3 * * *"
    retry_value = 3
else:
    execution_schedule = None
    retry_value = 0


@dag(
    start_date=datetime(2026, 2, 2, tz="America/Chicago"),
    schedule=execution_schedule,
    catchup=False,
    default_args={"retries": retry_value},
    tags=["outlook_attachment"],
)
def DRIVER_OUTLOOK_ATTACHMENT(tables=""):
    @task
    def EXTRACT_OUTLOOK_ATTACHMENTS(tables):
        print("Started EXTRACT_OUTLOOK_ATTACHMENTS")
        tables_param = [t.strip() for t in tables.split(',') if t.strip()] if tables else None
        if tables_param:
            print(f"Processing specific tables: {tables_param}")
        result = GOA.main(tables=tables_param)
        print("Completed EXTRACT_OUTLOOK_ATTACHMENTS")
        return result

    EXTRACT_OUTLOOK_ATTACHMENTS(tables)


DRIVER_OUTLOOK_ATTACHMENT(tables="")
