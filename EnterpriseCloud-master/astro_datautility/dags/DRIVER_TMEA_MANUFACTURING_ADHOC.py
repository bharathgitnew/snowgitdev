import os
import json
import logging
from pathlib import Path
from pendulum import datetime
from collections import defaultdict

from airflow.decorators import dag
from airflow.utils.task_group import TaskGroup
from airflow.operators.python import PythonOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

from include.Python.getSapR3Data import main
from include.Python.dbt_run_operator_new_platform import create_dbt_task, create_dbt_task_test


ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']
logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME=='PROD':
    execution_schedule="55 21,11 * * *"
    retry_value=0
else:
    execution_schedule=None
    retry_value=0

BASE_DIR                = '/usr/local/airflow'
CONFIG_INSERT_OVERWRITE = os.path.join(BASE_DIR, "include", "Configuration", "TelTools_SapR3_Tmea_Manufacturing_ADHOC.json")

CHUNK_GROUPS = {
    "Group_A": 300000,
    "Group_B": 10000,
    "Group_C": 100000,
    "Group_D": 60000,
    "Group_E": 150000,
    "Group_F": 75000,
    "Group_G": 250000,
}

def _load_active_tables(config_path):
    config = json.loads(Path(config_path).read_text())
    return [
        (name, spec)
        for name, spec in config.get("extraction", {}).items()
        if spec.get("is_active", False)
    ]

def _group_by_chunk(tables, default_chunk):
    groups = defaultdict(list)
    for table_name, spec in tables:
        chunk = spec.get("chunk_size", default_chunk)
        groups[chunk].append((table_name, spec))
    return dict(sorted(groups.items()))

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=execution_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["tmea_manufacturing_adhoc"],
)
def DRIVER_TMEA_MANUFACTURING_ADHOC(dbt_folder,domainGuid):

    with TaskGroup(group_id="TMEA_MANUFACTURING_ADHOC_TABLE_LOAD") as TMEA_MANUFACTURING_ADHOC_TABLE_LOAD:

        io_tables  = _load_active_tables(CONFIG_INSERT_OVERWRITE)
        io_buckets = _group_by_chunk(io_tables, default_chunk=100000)

        for group_name, bucket_chunk in CHUNK_GROUPS.items():
            if bucket_chunk not in io_buckets:
                continue

            with TaskGroup(group_id=group_name):
                for table_name, spec in io_buckets[bucket_chunk]:
                    PythonOperator(
                        task_id=f"{table_name}",
                        python_callable=main,
                        op_kwargs={
                            "config_file":     CONFIG_INSERT_OVERWRITE,
                            "extraction_name": table_name,
                            "env":             "PROD" if ASTRO_DEPLOYMENT_NAME == "PROD" else "QA",
                            "chunk_size":      bucket_chunk,
                            "queue_max_size":  5,
                            "debug":           False,
                            "full_reload":     False,
                        },
                    )

    TMEA_MANUFACTURING_ADHOC_DBT = create_dbt_task(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TMEA_MANUFACTURING_ADHOC_DBT"
        }
    )

    TMEA_MANUFACTURING_ADHOC_TESTS = create_dbt_task_test(
        **{
            "Base_directory" : os.path.dirname(__file__),
            "model_name": dbt_folder,
            "task_id" : "TMEA_MANUFACTURING_ADHOC_TESTS"
        }
    )

    TMEA_MANUFACTURING_ADHOC_ATLAN_UPLOAD = TriggerDagRunOperator(
        task_id='TMEA_MANUFACTURING_ADHOC_ATLAN_UPLOAD',
        trigger_dag_id='SYSTEM_UPDATE_ATLAN',
        conf={"domainGuid": domainGuid},
        wait_for_completion=True
        )

    TMEA_MANUFACTURING_ADHOC_TABLE_LOAD >>TMEA_MANUFACTURING_ADHOC_DBT >> TMEA_MANUFACTURING_ADHOC_TESTS >> TMEA_MANUFACTURING_ADHOC_ATLAN_UPLOAD


DRIVER_TMEA_MANUFACTURING_ADHOC(dbt_folder="tmea_manufacturing",domainGuid="264ae4b4-fe7e-43de-be7e-f53551f9592b")
