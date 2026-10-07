import sys

import include.Python.cleanupMondayUpdatesSync as CMUS
import include.Python.getDevOpsData as GWID
import include.Python.getMondayDotComUpdates as GMU
import include.Python.postMondayDotCom as PMD
import include.Python.postMondayUpdatesToDevOps as PMUD


def run_step(step_name, step_main, item_ids=None):
    print(f"Started {step_name}")
    try:
        result = step_main(item_ids=item_ids)
    except Exception as exc:
        print(f"{step_name} failed: {exc}")
        return {
            "status": "FAILED",
            "step": step_name,
            "error": str(exc),
        }

    if result.get("status") != "SUCCESS":
        print(f"{step_name} failed: {result.get('error', result)}")
        return {
            "status": "FAILED",
            "step": step_name,
            "result": result,
            "error": result.get("error", str(result)),
        }

    print(f"Completed {step_name}")
    return {
        "status": "SUCCESS",
        "step": step_name,
        "result": result,
    }


def main(item_ids=None):
    results = []

    extract_work_items_result = run_step("EXTRACT_WORK_ITEMS", GWID.main, item_ids=item_ids)
    results.append(extract_work_items_result)
    if extract_work_items_result["status"] != "SUCCESS":
        return {
            "status": "FAILED",
            "failed_step": "EXTRACT_WORK_ITEMS",
            "results": results,
            "error": extract_work_items_result.get("error", "EXTRACT_WORK_ITEMS failed"),
        }

    post_to_monday_result = run_step("POST_TO_MONDAY", PMD.main, item_ids=item_ids)
    results.append(post_to_monday_result)
    if post_to_monday_result["status"] != "SUCCESS":
        return {
            "status": "FAILED",
            "failed_step": "POST_TO_MONDAY",
            "results": results,
            "error": post_to_monday_result.get("error", "POST_TO_MONDAY failed"),
        }

    extract_monday_updates_result = run_step("EXTRACT_MONDAY_UPDATES", GMU.main, item_ids=item_ids)
    results.append(extract_monday_updates_result)
    if extract_monday_updates_result["status"] != "SUCCESS":
        return {
            "status": "FAILED",
            "failed_step": "EXTRACT_MONDAY_UPDATES",
            "results": results,
            "error": extract_monday_updates_result.get("error", "EXTRACT_MONDAY_UPDATES failed"),
        }

    post_monday_updates_to_devops_result = run_step("POST_MONDAY_UPDATES_TO_DEVOPS", PMUD.main, item_ids=item_ids)
    results.append(post_monday_updates_to_devops_result)
    if post_monday_updates_to_devops_result["status"] != "SUCCESS":
        return {
            "status": "FAILED",
            "failed_step": "POST_MONDAY_UPDATES_TO_DEVOPS",
            "results": results,
            "error": post_monday_updates_to_devops_result.get("error", "POST_MONDAY_UPDATES_TO_DEVOPS failed"),
        }

    cleanup_monday_updates_sync_result = run_step("CLEANUP_MONDAY_UPDATES_SYNC", CMUS.main, item_ids=item_ids)
    results.append(cleanup_monday_updates_sync_result)
    if cleanup_monday_updates_sync_result["status"] != "SUCCESS":
        return {
            "status": "FAILED",
            "failed_step": "CLEANUP_MONDAY_UPDATES_SYNC",
            "results": results,
            "error": cleanup_monday_updates_sync_result.get("error", "CLEANUP_MONDAY_UPDATES_SYNC failed"),
        }

    return {
        "status": "SUCCESS",
        "steps_completed": 5,
        "results": results,
    }


if __name__ == "__main__":
    result = main(item_ids=sys.argv[1:] if len(sys.argv) > 1 else None)
    sys.exit(0 if result.get("status") == "SUCCESS" else 1)