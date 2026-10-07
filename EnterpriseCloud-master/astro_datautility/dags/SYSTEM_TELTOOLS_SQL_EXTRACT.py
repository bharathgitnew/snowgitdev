import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime

import include.Python.TelTools_SQLServer as tts

logger = logging.getLogger("airflow.task")

CONFIG_BASE_PATH = "/usr/local/airflow/include/Configuration"


@dag(
    start_date=datetime(2025, 9, 2, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    default_args={"retries": 0},
    tags=["teltools_extract"],
    params={
        "config_filename": "TelTools_SQLServer_ADS-MADataSilver_Extract.json",
        "table_name": "PUT_TABLE_NAME_HERE",
    },
)
def SYSTEM_TELTOOLS_SQL_EXTRACT():

    @task
    def RUN_SINGLE_SQLSERVER_EXTRACT(config_filename, table_name):
        """
        TelTools SQLServer extract for a single table.
        """
        file_path = os.path.join(CONFIG_BASE_PATH, config_filename)

        logger.info("Starting TelTools SQLServer extract")
        logger.info("Config file   : %s", file_path)
        logger.info("Table name    : %s", table_name)

        tts.main(file_path, table_name)

        logger.info("Completed TelTools SQLServer extract")

    RUN_SINGLE_SQLSERVER_EXTRACT(
        config_filename="{{ params.config_filename }}",
        table_name="{{ params.table_name }}",
    )


_TELTOOLS_SQL_EXTRACT_DAG = SYSTEM_TELTOOLS_SQL_EXTRACT()
