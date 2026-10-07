import os
import json
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from airflow.operators.trigger_dagrun import TriggerDagRunOperator


ASTRO_DEPLOYMENT_NAME = os.environ["ASTRO_DEPLOYMENT_NAME"]
logger = logging.getLogger("airflow.task")

#if ASTRO_DEPLOYMENT_NAME == "PROD":
#    exectuion_schedule = "00 05 * * *"
#    retry_value = 3
#else:
exectuion_schedule = None
retry_value = 0


@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=exectuion_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["tea_intel_sms"],
)
def DRIVER_WORKDAY(config_copy_file):

    WORKDAY_DBT = TriggerDagRunOperator(
        task_id="WORKDAY_DBT",
        trigger_dag_id="DBT_EXECUTION",
        conf={"model_name": "tag:workday --exclude pub.*"},
        wait_for_completion=True,
    )

    WORKDAY_ATTENDANCE_EXTRACT = TriggerDagRunOperator(
        task_id="WORKDAY_ATTENDANCE_EXTRACT",
        trigger_dag_id="SYSTEM_GET_SFTP_FILES",
        conf={
            "config_path": "/usr/local/airflow/include/Configuration/TelTools_SFTPFile.json",
            "section": "TEL_Workday_USA-Attendance_Status",
        },
        wait_for_completion=True,
    )

    WORKDAY_CAMPAIGN_EXTRACT = TriggerDagRunOperator(
        task_id="WORKDAY_CAMPAIGN_EXTRACT",
        trigger_dag_id="SYSTEM_GET_SFTP_FILES",
        conf={
            "config_path": "/usr/local/airflow/include/Configuration/TelTools_SFTPFile.json",
            "section": "TEL_Workday_USA-Campaign",
        },
        wait_for_completion=True,
    )

    @task
    def BUILD_COPY_CONFS(config_copy_file) :
        with open(config_copy_file, 'r') as file:
            data=json.load(file)

        return [
            {
                "config_path": config_copy_file,
                "section": table
            } 
            for table in [
                dataset_key for dataset_key, _ in data["CopyFile"].items()
            ]
        ]

    COPY_CONFIGS = BUILD_COPY_CONFS(config_copy_file)

    WORKDAY_COPY_FILE = TriggerDagRunOperator.partial(
        task_id="COPY_FILE",
        trigger_dag_id="SYSTEM_COPY_FILE",
        wait_for_completion=True,
        max_active_tis_per_dag=1, 
        map_index_template="{{ task.conf.table_name }}"
    ).expand(conf=COPY_CONFIGS)

    (
        [WORKDAY_ATTENDANCE_EXTRACT, WORKDAY_CAMPAIGN_EXTRACT]
        >> WORKDAY_COPY_FILE
        >> WORKDAY_DBT
    )


DRIVER_WORKDAY(
    config_copy_file="/usr/local/airflow/include/Configuration/TelTools_CopyFile_Workday.json"
)
