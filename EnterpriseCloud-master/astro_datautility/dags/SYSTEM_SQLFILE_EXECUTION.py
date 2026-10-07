import os
import logging
from airflow.decorators import dag, task
from pendulum import datetime
from snowflake.connector import connect as conn
from airflow.models.param import Param

ASTRO_DEPLOYMENT_NAME=os.environ['ASTRO_DEPLOYMENT_NAME']

logger = logging.getLogger("airflow.task")

@dag(
    start_date=datetime(2025, 9, 1, tz="America/Chicago"),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    tags=["sql_file_execution"],
    params={
        'FileName': Param(
            type=["string"], 
            description='Required text of the file name to be execute. Ex: /usr/local/airflow/include/Snowflake/query.sql'
        ),
        'query_tag': Param(
            None, 
            type=["null", "string"], 
            description='Optional text to tag all run queries in Snowflake for easier lookup.'
        ),
        'is_dynamic': Param(
            False, 
            type=["boolean"], 
            description='Optional boolean set to True if the file is a sql generator that needs to additionally run each line of output. Default is set to False.',
        ),
    },
)
def SYSTEM_SQLFILE_EXECUTION():
    @task
    def SYSTEM_SQLFILE_EXECUTION(**kwargs):
        
        FileName = kwargs['params']['FileName']
        query_tag = kwargs['params']['query_tag']
        is_dynamic = kwargs['params']['is_dynamic']

        SFAccount     = os.environ.get("SNOWFLAKE_ACCOUNT")
        SFUsername    = os.environ.get("SNOWFLAKE_USER")
        SFPassword    = os.environ.get("SNOWFLAKE_SECRET")
        SFRole        = 'SYSADMIN'
        SFWarehouse   = os.environ.get('SNOWFLAKE_WAREHOUSE')
        SFDatabase    = 'ADMIN'
        SFSchema      = 'PUBLIC'

        connection = conn(
            account=SFAccount, 
            user=SFUsername, 
            password=SFPassword, 
            database=SFDatabase, 
            schema=SFSchema, 
            role=SFRole, 
            warehouse=SFWarehouse, 
            data=None, 
            autocommit=None,
            session_parameters={
                "QUERY_TAG": query_tag
            },
        )
        logger.info(f'Connection made with session_id: {connection.session_id}')

        with open(FileName, 'r') as file:
            SQLStatement = file.read()
        cursor_list = connection.execute_string(SQLStatement)

        for cursor in cursor_list:
            logger.info(f'query: {SQLStatement}')
            logger.info(f'query_id: {cursor.sfqid}')
            logger.info(f'row count: {cursor.rowcount}')

            if is_dynamic:
                qnum = 1
                for row in cursor:
                    result_list = connection.execute_string(row[0])
                    for result in result_list:
                        logger.info(f'sub query ({qnum}/{cursor.rowcount}): {row[0]}')
                        logger.info(f'sub query_id: {result.sfqid}')
                        logger.info(f'sub row count: {result.rowcount}')
                    qnum += 1

    SYSTEM_SQLFILE_EXECUTION()

SYSTEM_SQLFILE_EXECUTION()