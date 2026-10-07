import os
import json
from  pathlib import Path
from airflow.operators.bash import BashOperator

ENV_CONFIG_PATH = r'/usr/local/airflow/include/Configuration/TelTools_Environment.json'

def create_dbt_task(Base_directory : str ,model_name: str, task_id: str = None) -> BashOperator:

    BASE_DIR = Base_directory
    DBT_PROJECT = os.path.join(BASE_DIR, "dbt", "dbt_project")
    DBT_VENV = f"{os.environ['AIRFLOW_HOME']}/dbt_venv/bin/activate"

    env_vars = {
        k: os.getenv(v)
        for k, v in json.loads(Path(ENV_CONFIG_PATH).read_text()).items()
    }

    DBT_PROFILES = f"{DBT_PROJECT}/{env_vars['ASTRO_DEPLOYMENT_NAME']}_PROFILES"
    env_vars.update({
        "DBT_VENV": DBT_VENV,
        "DBT_PROFILES": DBT_PROFILES,
        "MODEL_NAME": model_name,
    })

    _command = "{ " + ", ".join([f'{k}: ${k}' for k in env_vars.keys()]) + " }"

    bash_command = (
        "source $DBT_VENV && "
        "dbt deps && "
        "sleep 10 && "
        f'dbt run --profiles-dir $DBT_PROFILES --vars "{_command}" '
        "--select $MODEL_NAME"
    )

    return BashOperator(
        task_id=task_id or f"dbt_{model_name.lower()}",
        bash_command=bash_command,
        cwd=DBT_PROJECT,
        env=env_vars,
    )
