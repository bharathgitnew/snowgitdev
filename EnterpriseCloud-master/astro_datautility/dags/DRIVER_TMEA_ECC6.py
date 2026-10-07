import os
import json
import logging
from pathlib import Path
from pendulum import datetime
from collections import defaultdict

from airflow.decorators import dag
from airflow.operators.python import PythonOperator
from airflow.utils.task_group import TaskGroup

from include.Python.getSapR3Data import main

ASTRO_DEPLOYMENT_NAME = os.environ['ASTRO_DEPLOYMENT_NAME']
logger = logging.getLogger("airflow.task")

if ASTRO_DEPLOYMENT_NAME == 'PROD':
    execution_schedule = "0 0 * * *"
    retry_value        = 0
else:
    execution_schedule = None
    retry_value        = 0

BASE_DIR                = '/usr/local/airflow'
CONFIG_INSERT_OVERWRITE = os.path.join(BASE_DIR, "include", "Configuration", "TelTools_SapR3_InsertOverwrite.json")
CONFIG_MERGE            = os.path.join(BASE_DIR, "include", "Configuration", "TelTools_SapR3_Merge.json")

CHUNK_GROUPS = {
    "Group_A": 300000,
    "Group_B": 10000,
    "Group_C": 100000,
    "Group_D": 60000,
    "Group_E": 150000,
    "Group_F": 75000,
    "Group_G": 250000,
    "GROUP_H": 50000,
    "Group_I": 200000,
}

def _load_active_tables(config_path):
    config = json.loads(Path(config_path).read_text())
    return [
        (name, spec)
        for name, spec in config.get("extraction", {}).items()
        if spec.get("is_active", False)
    ]


def _group_by_chunk(tables, default_chunk) :
    groups = defaultdict(list)
    for table_name, spec in tables:
        chunk = spec.get("chunk_size", default_chunk)
        groups[chunk].append((table_name, spec))
    return dict(sorted(groups.items()))


@dag(
    start_date=datetime(2026, 1, 1, tz="America/Chicago"),
    schedule=execution_schedule,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": retry_value},
    tags=["tmea"],
    max_active_tasks=8
)
def DRIVER_TMEA_ECC6(env, chunk_size, full_reload, debug, queue_max_size=5):

    with TaskGroup(group_id="insert_overwrite_tasks"):
        io_tables  = _load_active_tables(CONFIG_INSERT_OVERWRITE)
        io_buckets = _group_by_chunk(io_tables, default_chunk=chunk_size)

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
                            "env":             env,
                            "chunk_size":      bucket_chunk,
                            "queue_max_size":  queue_max_size,
                            "debug":           debug,
                            "full_reload":     full_reload,
                        },
                    )

    # with TaskGroup(group_id="merge_tasks"):
    #     merge_tables  = _load_active_tables(CONFIG_MERGE)
    #     merge_buckets = _group_by_chunk(merge_tables, default_chunk=chunk_size)

    #     for bucket_chunk, bucket_tables in merge_buckets.items():
    #         with TaskGroup(group_id=f"chunk_{bucket_chunk}"):
    #             for table_name, spec in bucket_tables:
    #                 PythonOperator(
    #                     task_id=f"{table_name}",
    #                     python_callable=main,
    #                     op_kwargs={
    #                         "config_file":      CONFIG_MERGE,
    #                         "extraction_name":  table_name,
    #                         "env":              env,
    #                         "chunk_size":       bucket_chunk,
    #                         "full_reload":      full_reload,
    #                         "queue_max_size":   queue_max_size,
    #                         "debug":            debug,
    #                     },
    #                 )


DRIVER_TMEA_ECC6(
    env            = "PROD" if ASTRO_DEPLOYMENT_NAME == "PROD" else "QA",
    chunk_size     = 100000,
    queue_max_size = 5,
    full_reload    = False,
    debug          = False,
)
