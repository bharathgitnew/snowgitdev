import os
from airflow.decorators import dag, task
from airflow.exceptions import AirflowFailException
from pendulum import datetime
import include.Python.getDevOpsData as GWID
import include.Python.postMondayDotCom as PMD
import include.Python.getMondayDotComUpdates as GMU
import include.Python.postMondayUpdatesToDevOps as PMUD
import include.Python.cleanupMondayUpdatesSync as CMUS


ASTRO_DEPLOYMENT_NAME = os.environ.get('ASTRO_DEPLOYMENT_NAME', 'DEV')

if ASTRO_DEPLOYMENT_NAME == 'PROD':
    execution_schedule = "0 4 * * *"
    retry_value = 3
else:
    execution_schedule = None
    retry_value = 0


@dag(
    start_date=datetime(2026, 2, 2, tz="America/Chicago"),
    schedule=execution_schedule,
    catchup=False,
    default_args={"retries": retry_value},
    tags=["devops_to_monday"],
)
def DRIVER_DEVOPS_SF_MONDAY(item_ids=""):
    @task
    def EXTRACT_WORK_ITEMS(item_ids):
        print("Started EXTRACT_WORK_ITEMS")
        ids_param = [t.strip() for t in item_ids.split(',') if t.strip()] if item_ids else None
        if ids_param:
            print(f"Processing specific item IDs: {ids_param}")
        result = GWID.main(item_ids=ids_param)
        if result.get("status") != "SUCCESS":
            raise AirflowFailException(f"EXTRACT_WORK_ITEMS failed: {result.get('error', result)}")
        print("Completed EXTRACT_WORK_ITEMS")
        return result

    @task
    def POST_TO_MONDAY(item_ids):
        print("Started POST_TO_MONDAY")
        ids_param = [t.strip() for t in item_ids.split(',') if t.strip()] if item_ids else None
        if ids_param:
            print(f"Processing specific item IDs: {ids_param}")
        result = PMD.main(item_ids=ids_param)
        if result.get("status") != "SUCCESS":
            raise AirflowFailException(f"POST_TO_MONDAY failed: {result.get('error', result)}")
        print("Completed POST_TO_MONDAY")
        return result

    @task
    def EXTRACT_MONDAY_UPDATES(item_ids):
        print("Started EXTRACT_MONDAY_UPDATES")
        ids_param = [t.strip() for t in item_ids.split(',') if t.strip()] if item_ids else None
        if ids_param:
            print(f"Processing specific item IDs: {ids_param}")
        result = GMU.main(item_ids=ids_param)
        if result.get("status") != "SUCCESS":
            raise AirflowFailException(f"EXTRACT_MONDAY_UPDATES failed: {result.get('error', result)}")
        print("Completed EXTRACT_MONDAY_UPDATES")
        return result

    @task
    def POST_MONDAY_UPDATES_TO_DEVOPS(item_ids):
        print("Started POST_MONDAY_UPDATES_TO_DEVOPS")
        ids_param = [t.strip() for t in item_ids.split(',') if t.strip()] if item_ids else None
        if ids_param:
            print(f"Processing specific item IDs: {ids_param}")
        result = PMUD.main(item_ids=ids_param)
        if result.get("status") != "SUCCESS":
            raise AirflowFailException(f"POST_MONDAY_UPDATES_TO_DEVOPS failed: {result.get('error', result)}")
        print("Completed POST_MONDAY_UPDATES_TO_DEVOPS")
        return result

    @task
    def CLEANUP_MONDAY_UPDATES_SYNC(item_ids):
        print("Started CLEANUP_MONDAY_UPDATES_SYNC")
        ids_param = [t.strip() for t in item_ids.split(',') if t.strip()] if item_ids else None
        if ids_param:
            print(f"Processing specific item IDs: {ids_param}")
        result = CMUS.main(item_ids=ids_param)
        if result.get("status") != "SUCCESS":
            raise AirflowFailException(f"CLEANUP_MONDAY_UPDATES_SYNC failed: {result.get('error', result)}")
        print("Completed CLEANUP_MONDAY_UPDATES_SYNC")
        return result

    extract_result = EXTRACT_WORK_ITEMS(item_ids)
    post_result = POST_TO_MONDAY(item_ids)
    extract_monday_updates_result = EXTRACT_MONDAY_UPDATES(item_ids)
    post_monday_updates_result = POST_MONDAY_UPDATES_TO_DEVOPS(item_ids)
    cleanup_monday_updates_result = CLEANUP_MONDAY_UPDATES_SYNC(item_ids)
    extract_result >> post_result >> extract_monday_updates_result >> post_monday_updates_result >> cleanup_monday_updates_result


DRIVER_DEVOPS_SF_MONDAY(item_ids="")