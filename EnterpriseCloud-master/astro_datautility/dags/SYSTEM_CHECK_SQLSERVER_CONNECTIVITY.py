"""
SYSTEM_CHECK_SQLSERVER_CONNECTIVITY_dag.py
=================================

Airflow DAG that verifies SQL Server connectivity via pyodbc.

Connection details are dynamic: trigger the DAG with "Trigger DAG w/ config" and a
form appears with fields for server, database, username, and password. The task
opens a pyodbc connection with those values and runs `SELECT 1`.
"""

from datetime import datetime

from airflow.decorators import dag, task
from airflow.models.param import Param
from airflow.operators.python import get_current_context


@dag(
    dag_id="SYSTEM_CHECK_SQLSERVER_CONNECTIVITY",
    description="Verify SQL Server connectivity via pyodbc (SELECT 1)",
    schedule=None,
    start_date=datetime(2026, 1, 1),
    catchup=False,
    tags=["healthcheck", "sqlserver"],
    params={
        "server": Param("", type="string", title="Server",
                        description="e.g. teloutdbp002.asia.tel.com"),
        "database": Param("", type="string", title="Database",
                          description="e.g. TEL_GWS"),
        "username": Param("", type="string", title="Username"),
        "password": Param("", type="string", title="Password"),
        "driver": Param("{SQL Server Native Client 11.0}", type="string",
                        title="ODBC Driver",
                        description="or {ODBC Driver 17 for SQL Server}"),
    },
)
def SYSTEM_CHECK_SQLSERVER_CONNECTIVITY():

    @task
    def test_connection():
        import pyodbc

        p = get_current_context()["params"]

        missing = [k for k in ("server", "database", "username", "password")
                   if not p.get(k)]
        if missing:
            raise ValueError(f"Missing required connection details: {', '.join(missing)}")

        conn_str = (
            f"Driver={p['driver']};"
            f"Server={p['server']};"
            f"Database={p['database']};"
            f"UID={p['username']};"
            f"PWD={p['password']};"
        )

        print(f"Connecting to {p['server']} / {p['database']} as {p['username']} ...")
        conn = pyodbc.connect(conn_str, timeout=10)
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT 1")
            result = cursor.fetchone()
            cursor.execute("SELECT @@VERSION")
            version = cursor.fetchone()[0]
            print(f"Connection OK — SELECT 1 returned {result[0]}")
            print(f"Server version: {version}")
        finally:
            conn.close()

    test_connection()


SYSTEM_CHECK_SQLSERVER_CONNECTIVITY()