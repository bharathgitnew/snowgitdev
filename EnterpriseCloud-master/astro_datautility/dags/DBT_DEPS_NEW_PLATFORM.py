import os
import json
import logging
from pathlib import Path
from pendulum import datetime

from airflow.decorators import dag
from airflow.operators.bash import BashOperator

ENV_CONFIG_PATH = r"/usr/local/airflow/include/Configuration/TelTools_Environment.json"

env_vars = {
    k: os.getenv(v)
    for k, v in json.loads(Path(ENV_CONFIG_PATH).read_text()).items()
}

BASE_DIR = os.path.dirname(__file__)
DBT_VENV = f"{os.environ['AIRFLOW_HOME']}/dbt_venv/bin/activate"
DBT_PROJECT = f"{BASE_DIR}/dbt/dbt_tel"
DBT_PROFILES = f"{DBT_PROJECT}/{env_vars['ASTRO_DEPLOYMENT_NAME']}_PROFILES"

logger = logging.getLogger("airflow.task")

@dag(
    start_date=datetime(2024, 9, 6, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    tags=["dbt_new_arch_execution"],
)
def DBT_DEPS_NEW_PLATFORM():

    runtime_env = dict(env_vars)
    runtime_env.update(
        {
            "DBT_VENV": DBT_VENV,
            "DBT_PROFILES": DBT_PROFILES
        }
    )

    _command = "{ " + ", ".join([f'{k}: ${k}' for k in env_vars.keys()]) + " }"

    bash_command = (
        "source $DBT_VENV && "
        "dbt deps "
        f'--profiles-dir $DBT_PROFILES --vars "{_command}" '
    )

    BashOperator(
        task_id="DBT_DEPS_NEW_PLATFORM",
        cwd=DBT_PROJECT,
        env=runtime_env,
        bash_command=bash_command,
    )


DBT_DEPS_NEW_PLATFORM()
