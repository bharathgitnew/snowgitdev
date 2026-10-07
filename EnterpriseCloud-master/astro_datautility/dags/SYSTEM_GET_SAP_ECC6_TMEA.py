import os
import logging
from airflow.decorators import dag
from airflow.operators.python import PythonOperator
from pendulum import datetime
from include.Python.getSapR3Data import main, _parse_bool

ASTRO_DEPLOYMENT_NAME = os.environ['ASTRO_DEPLOYMENT_NAME']
logger = logging.getLogger("airflow.task")

BASE_DIR   = '/usr/local/airflow'
CONFIG_DIR = os.path.join(BASE_DIR, "include", "Configuration")

CONFIG_ALIASES = {
    "merge": os.path.join(CONFIG_DIR, "TelTools_SapR3_Merge.json"),
    "insert_overwrite": os.path.join(CONFIG_DIR, "TelTools_SapR3_InsertOverwrite.json"),
    "mini_orch": os.path.join(CONFIG_DIR, "TelTools_SapR3_InsertOverwrite_Mini_Orch.json"),
    "insert_overwrite_11pm": os.path.join(CONFIG_DIR, "TelTools_SapR3_InsertOverwrite_11pm.json"),
}


def _resolve_config_file(config_file: str) -> str:
    if config_file in CONFIG_ALIASES:
        return CONFIG_ALIASES[config_file]
    if os.path.isabs(config_file):
        return config_file
    return os.path.join(CONFIG_DIR, config_file)


def _run_sap_extraction(extraction_name, config_file, env, chunk_size, full_reload, debug, queue_max_size):
    resolved_config_file = _resolve_config_file(config_file)

    if not os.path.exists(resolved_config_file):
        raise FileNotFoundError(f"Config file not found: {resolved_config_file}")

    main(
        config_file=resolved_config_file,
        extraction_name=extraction_name,
        env=env,
        chunk_size=int(chunk_size),
        full_reload=_parse_bool(full_reload),
        debug=_parse_bool(debug),
        queue_max_size=int(queue_max_size),
    )


@dag(
    start_date=datetime(2026, 1, 1, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": 0},
    tags=["tmea", "debug"],
    params={
        "extraction_name": "MAKT",
        "config_file":     "insert_overwrite",
        "env":             "PROD" if ASTRO_DEPLOYMENT_NAME == "PROD" else "QA",
        "chunk_size":      200_000,
        "queue_max_size":  0,
        "full_reload":     False,
        "debug":           True,
    },
)
def SYSTEM_GET_SAP_ECC6_TMEA():
    PythonOperator(
        task_id="extract_table",
        python_callable=_run_sap_extraction,
        op_kwargs={
            "extraction_name": "{{ params.extraction_name }}",
            "config_file":     "{{ params.config_file }}",
            "env":             "{{ params.env }}",
            "chunk_size":      "{{ params.chunk_size }}",
            "queue_max_size":  "{{ params.queue_max_size }}",
            "full_reload":     "{{ params.full_reload }}",
            "debug":           "{{ params.debug }}",
        },
    )


SYSTEM_GET_SAP_ECC6_TMEA()
