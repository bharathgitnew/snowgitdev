import logging
import os
import sys
from datetime import datetime, timedelta, timezone

from include.Python.TELTools import getSnowFlakeConn, read_runtime_config
import include.Python.postMondayUpdatesToDevOps as PMUD


logger = logging.getLogger(__name__)
if not logger.handlers:
    handler = logging.StreamHandler()
    handler.setFormatter(logging.Formatter('%(asctime)s %(levelname)s - %(message)s', '%Y-%m-%d %H:%M:%S'))
    logger.addHandler(handler)
logger.setLevel(logging.INFO)

logging.getLogger('azure').setLevel(logging.WARNING)
logging.getLogger('snowflake.connector').setLevel(logging.WARNING)

POSTED_RETENTION_DAYS = max(int(os.environ.get("MONDAY_UPDATES_POSTED_RETENTION_DAYS", "7")), 0)


def execute_scalar(conn, query):
    cursor = conn.cursor()
    try:
        cursor.execute(query)
        result = cursor.fetchone()
        return int(result[0]) if result and result[0] is not None else 0
    finally:
        cursor.close()


def execute_delete(conn, query):
    cursor = conn.cursor()
    try:
        cursor.execute(query)
    finally:
        cursor.close()


def process_project(project, db):
    project_id = project.get("id")
    sf_config = project.get("WorkItemDetails", {}).get("SnowflakeConn", {})
    schema = sf_config["SNOWFLAKE_SCHEMA_NAME"]
    base_table = sf_config["SNOWFLAKE_TABLE_NAME"]
    stage_table = PMUD.get_updates_stage_table_name(base_table)
    posted_table = PMUD.get_posted_updates_table_name(base_table)
    control_key = PMUD.get_post_control_key(base_table)

    logger.info(f"--- Cleaning Monday reverse-sync tables for project {project_id} ---")
    logger.info(f"Stage Table: {stage_table} | Posted Log: {posted_table}")

    runtime_result = read_runtime_config(db, schema)
    if not runtime_result["status"]:
        raise Exception(f"Unable to read control table for {schema}.{control_key}")

    last_posted_dt = None
    if runtime_result["data"]:
        last_posted_dt = PMUD.parse_timestamp(runtime_result["data"].get(control_key))

    if last_posted_dt is None:
        logger.info(f"No reverse-sync watermark found for {project_id}; skipping cleanup")
        return {
            "status": "SUCCESS",
            "project_id": project_id,
            "stage_deleted": 0,
            "posted_deleted": 0,
            "skipped": True,
        }

    conn, messages = getSnowFlakeConn(db, schema, [])
    if conn == 'no connection':
        raise Exception(f"Snowflake connection failed for {schema}: {messages}")

    watermark = PMUD.format_timestamp(last_posted_dt)
    retention_cutoff = PMUD.format_timestamp(datetime.now(timezone.utc) - timedelta(days=POSTED_RETENTION_DAYS))
    staged_event_ts_expr = (
        'COALESCE(staged.JSONFIELD:"event_created_at"::string, '
        'staged.JSONFIELD:"monday_reply_created_at"::string, '
        'staged.JSONFIELD:"monday_update_created_at"::string)'
    )
    posted_event_ts_expr = (
        'COALESCE(JSONFIELD:"event_created_at"::string, '
        'JSONFIELD:"monday_reply_created_at"::string, '
        'JSONFIELD:"monday_update_created_at"::string)'
    )

    try:
        PMUD.ensure_variant_stage_table(conn, stage_table)
        PMUD.ensure_variant_stage_table(conn, posted_table)

        stage_count_query = f"""
            SELECT COUNT(*)
            FROM {stage_table} AS staged
            WHERE TRY_TO_TIMESTAMP_TZ({staged_event_ts_expr}) <= TRY_TO_TIMESTAMP_TZ('{watermark}')
              AND staged.JSONFIELD:\"source_key\"::string IN (
                    SELECT DISTINCT posted.JSONFIELD:\"source_key\"::string
                    FROM {posted_table} AS posted
                    WHERE posted.JSONFIELD:\"source_key\"::string IS NOT NULL
              )
        """

        stage_delete_query = f"""
            DELETE FROM {stage_table} AS staged
                        WHERE TRY_TO_TIMESTAMP_TZ({staged_event_ts_expr}) <= TRY_TO_TIMESTAMP_TZ('{watermark}')
              AND staged.JSONFIELD:\"source_key\"::string IN (
                    SELECT DISTINCT posted.JSONFIELD:\"source_key\"::string
                    FROM {posted_table} AS posted
                    WHERE posted.JSONFIELD:\"source_key\"::string IS NOT NULL
              )
        """

        posted_count_query = f"""
            SELECT COUNT(*)
            FROM {posted_table}
                        WHERE TRY_TO_TIMESTAMP_TZ({posted_event_ts_expr}) <= TRY_TO_TIMESTAMP_TZ('{watermark}')
              AND TRY_TO_TIMESTAMP_TZ(JSONFIELD:\"devops_posted_at\"::string) <= TRY_TO_TIMESTAMP_TZ('{retention_cutoff}')
        """

        posted_delete_query = f"""
            DELETE FROM {posted_table}
                        WHERE TRY_TO_TIMESTAMP_TZ({posted_event_ts_expr}) <= TRY_TO_TIMESTAMP_TZ('{watermark}')
              AND TRY_TO_TIMESTAMP_TZ(JSONFIELD:\"devops_posted_at\"::string) <= TRY_TO_TIMESTAMP_TZ('{retention_cutoff}')
        """

        stage_deleted = execute_scalar(conn, stage_count_query)
        if stage_deleted:
            execute_delete(conn, stage_delete_query)

        posted_deleted = execute_scalar(conn, posted_count_query)
        if posted_deleted:
            execute_delete(conn, posted_delete_query)

        logger.info(
            f"Cleanup completed for {project_id}: stage_deleted={stage_deleted}, posted_deleted={posted_deleted}, retention_days={POSTED_RETENTION_DAYS}"
        )

        return {
            "status": "SUCCESS",
            "project_id": project_id,
            "stage_deleted": stage_deleted,
            "posted_deleted": posted_deleted,
            "skipped": False,
        }
    finally:
        conn.close()


def main(item_ids=None):
    try:
        db = os.environ["SNOWFLAKE_LZ"]
        if item_ids:
            item_ids = [item_id.upper() for item_id in item_ids]

        monday_projects = PMUD.get_monday_enabled_projects(item_ids=item_ids)
        if item_ids and not monday_projects:
            logger.info(f"No Monday-enabled projects selected for item IDs: {', '.join(item_ids)}")
            return {
                "status": "SUCCESS",
                "projects_total": 0,
                "projects_cleaned": 0,
                "projects_failed": 0,
                "stage_deleted": 0,
                "posted_deleted": 0,
                "results": [],
            }

        results = []
        total_stage_deleted = 0
        total_posted_deleted = 0
        for project in monday_projects:
            try:
                result = process_project(project, db)
            except Exception as exc:
                logger.error(f"Failed to clean Monday reverse-sync tables for {project.get('id')}: {exc}")
                result = {
                    "status": "FAILED",
                    "project_id": project.get("id"),
                    "stage_deleted": 0,
                    "posted_deleted": 0,
                    "error": str(exc),
                }
            results.append(result)
            if result["status"] == "SUCCESS":
                total_stage_deleted += result.get("stage_deleted", 0)
                total_posted_deleted += result.get("posted_deleted", 0)

        failures = [result for result in results if result["status"] != "SUCCESS"]
        return {
            "status": "FAILED" if failures else "SUCCESS",
            "projects_total": len(monday_projects),
            "projects_cleaned": len(results) - len(failures),
            "projects_failed": len(failures),
            "stage_deleted": total_stage_deleted,
            "posted_deleted": total_posted_deleted,
            "results": results,
        }
    except Exception as exc:
        logger.error(f"Critical error in Monday reverse-sync cleanup: {exc}")
        return {
            "status": "FAILED",
            "projects_total": 0,
            "projects_cleaned": 0,
            "projects_failed": 0,
            "stage_deleted": 0,
            "posted_deleted": 0,
            "results": [],
            "error": str(exc),
        }


if __name__ == "__main__":
    result = main(item_ids=sys.argv[1:] if len(sys.argv) > 1 else None)
    sys.exit(0 if result.get("status") == "SUCCESS" else 1)