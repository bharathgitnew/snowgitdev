"""
DAG to test a WASB connection using WasbHook (read-only).

This DAG tests a WASB connection by:
1. Checking the connection is valid
2. Listing containers in the storage account
3. Listing blobs in a specified container
"""

from datetime import datetime

from airflow import DAG
from airflow.operators.python import PythonOperator

WASB_CONN_ID = "GMX_PROD_BLOB_STORAGE"
TEST_CONTAINER = "sourcearchive"


def check_connection() -> dict:
    """Verify the WASB connection is configured correctly."""
    from airflow.hooks.base import BaseHook

    conn = BaseHook.get_connection(WASB_CONN_ID)
    extras = conn.extra_dejson

    result = {
        "conn_id": conn.conn_id,
        "conn_type": conn.conn_type,
        "host": conn.host,
        "has_managed_identity_client_id": "managed_identity_client_id" in extras
        or bool(conn.login),
        "has_workload_identity_tenant_id": "workload_identity_tenant_id" in extras,
        "extras_keys": list(extras.keys()),
    }
    print(result)
    return result

def list_containers() -> list[str]:
    """List all containers in the storage account."""
    from airflow.providers.microsoft.azure.hooks.wasb import WasbHook

    hook = WasbHook(wasb_conn_id=WASB_CONN_ID)
    blob_service_client = hook.get_conn()

    containers = [c.name for c in blob_service_client.list_containers()]
    print(f"Found {len(containers)} containers: {containers}")
    return containers

def list_blobs_in_container(container_name: str) -> list[str]:
    """List blobs in a container (read-only)."""
    from airflow.providers.microsoft.azure.hooks.wasb import WasbHook

    hook = WasbHook(wasb_conn_id=WASB_CONN_ID)
    blob_service_client = hook.get_conn()

    container_client = blob_service_client.get_container_client(container=container_name)
    blobs = [b.name for b in container_client.list_blobs()]
    print(f"Found {len(blobs)} blobs in '{container_name}': {blobs}")
    return blobs

with DAG(
    dag_id="test_azure_wasb_hook",
    schedule=None,
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=["azure", "managed-identity", "wasb", "test"],
    doc_md=__doc__,
) as dag:
    check_connection_task = PythonOperator(
        task_id="check_connection", python_callable=check_connection
    )
    list_containers_task = PythonOperator(
        task_id="list_containers", python_callable=list_containers
    )
    list_blobs_task = PythonOperator(
        task_id="list_blobs_in_container",
        python_callable=list_blobs_in_container,
        op_args=[TEST_CONTAINER],
    )

    check_connection_task >> list_containers_task >> list_blobs_task
