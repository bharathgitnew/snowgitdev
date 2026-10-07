import os
import json
import logging
from pathlib import Path

from pendulum import datetime
from airflow.decorators import dag
from airflow.operators.bash import BashOperator

ENV_CONFIG_PATH = "/usr/local/airflow/include/Configuration/TelTools_Environment.json"

env_vars = {
    k: os.getenv(v)
    for k, v in json.loads(Path(ENV_CONFIG_PATH).read_text()).items()
}

BASE_DIR = os.path.dirname(__file__)
DBT_PROJECT = f"{BASE_DIR}/dbt/dbt_project"
DBT_VENV = f"{os.environ['AIRFLOW_HOME']}/dbt_venv/bin/activate"

ASTRO_DEPLOYMENT_NAME = os.environ["ASTRO_DEPLOYMENT_NAME"]
DBT_PROFILES = f"{DBT_PROJECT}/{ASTRO_DEPLOYMENT_NAME}_PROFILES"

logger = logging.getLogger("airflow.task")


@dag(
    start_date=datetime(2024, 9, 6, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    tags=["dbt_execution"],
)
def DBT_EXECUTION(model_name: str):

    runtime_env = dict(env_vars)
    runtime_env.update(
        {
            "DBT_VENV": DBT_VENV,
            "DBT_PROFILES": DBT_PROFILES,
            "MODEL_NAME": model_name,
            "ASTRO_DEPLOYMENT_NAME": ASTRO_DEPLOYMENT_NAME,
        }
    )

    _command = "{ " + ", ".join([f'{k}: ${k}' for k in env_vars.keys()]) + " }"

    bash_command = (
        "source $DBT_VENV && "
        "dbt deps && "
        "sleep 10 && "
        f'dbt run --profiles-dir $DBT_PROFILES --vars "{_command}" '
        "--select $MODEL_NAME"
    )

    BashOperator(
        task_id="DBT_EXECUTION",
        cwd=DBT_PROJECT,
        env=runtime_env,
        bash_command=bash_command,
    )


DBT_EXECUTION(model_name="ODS__AZURE_DEVOPS__PULL_REQUESTS")
