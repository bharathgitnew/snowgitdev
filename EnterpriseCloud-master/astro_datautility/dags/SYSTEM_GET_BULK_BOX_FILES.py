"""
SYSTEM_GET_BULK_BOX_FILES
=========================
One param: config_file (e.g. box_configs.json)
- reads from include/Configuration/<config_file>
- uses the main JSON key as both lookup key and Snowflake table name
- creates one parallel task per folder in the config
"""

import os
import json
import logging
from pathlib import Path

from airflow.decorators import dag
from airflow.operators.python import PythonOperator
from airflow.utils.task_group import TaskGroup
from pendulum import datetime

from include.Python.getBulkBoxFiles import main

ASTRO_DEPLOYMENT_NAME = os.environ["ASTRO_DEPLOYMENT_NAME"]
logger        = logging.getLogger("airflow.task")
CONFIG_DIR    = "/usr/local/airflow/include/Configuration"
DEFAULT_FILE  = "TelTools_BulkBox_TTCA.json"


def _make_task_id(cfg: dict, index: int) -> str:
    name = cfg["folder_name"].rsplit(".", 1)[0] if "." in cfg["folder_name"] else cfg["folder_name"]
    safe = name.replace(" ", "_").replace("-", "_")
    return f"{index:02d}_{safe}"


def _run_single_config(folder_id, file_types, mode, table, **context):
    logger.info(f"folder_id={folder_id}  mode={mode}  table={table}")
    main(
        folder_id  = folder_id,
        file_types = file_types,
        mode       = mode,
        table      = table,
    )


def _load_config(config_file: str):
    """
    Read config file from include/Configuration/.
    Returns (config_key, configs_list)
    config_key  = main JSON key e.g. TTCA_BOX → becomes table name
    configs_list = list of folder dicts under that key
    """
    config_path = Path(CONFIG_DIR) / config_file

    with open(config_path) as f:
        all_configs = json.load(f)

    # take the first (and only) top-level key as the table name
    config_key   = list(all_configs.keys())[0]
    configs_list = all_configs[config_key]

    logger.info(f"Config file  : {config_file}")
    logger.info(f"Config key   : {config_key}  (table name)")
    logger.info(f"Folder count : {len(configs_list)}")

    return config_key, configs_list


def _build_dag_tasks(config_file: str):
    config_key, configs = _load_config(config_file)

    with TaskGroup(group_id="ingest_folders"):
        for i, cfg in enumerate(configs):
            PythonOperator(
                task_id         = _make_task_id(cfg, i),
                python_callable = _run_single_config,
                op_kwargs       = {
                    "folder_id":  cfg["folder_id"],
                    "file_types": cfg["file_types"],
                    "mode":       cfg["mode"],
                    "table":      config_key,  
                },
            )


@dag(
    start_date=datetime(2026, 1, 1, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": 0},
    tags=["bulk_box_files", "box", "azure_blob"],
    params={
        "config_file": DEFAULT_FILE,   # filename only, no path
    },
    max_active_tasks=5,
)
def SYSTEM_GET_BULK_BOX_FILES():
    _build_dag_tasks(DEFAULT_FILE)  


SYSTEM_GET_BULK_BOX_FILES()