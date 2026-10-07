
import subprocess
import datetime
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
from threading import Lock
import include.Python.TELTools as TT
import time
import os

DRIVER_NAME = "DRIVER_FINANCE_MINI"

CURRENT_TIMESTAMP = (
    datetime.datetime.now()
    .strftime("%Y_%m_%d_%H_%M_%S")
)

print_lock = Lock()

ENV = "PROD" if os.getenv("SNOWFLAKE_ENV", "").upper() == "PROD" else "TEST"


PYTHON_DIR = r'F:\Shares\astro_datautility'
OLD_DBT_DIR = r'F:\Shares\astro_datautility\dags\dbt\dbt_project'
NEW_DBT_DIR = r'F:\Shares\astro_datautility\dags\dbt\dbt_tel'
CONFIG_DIR = r'F:\Shares\astro_datautility\include\Configuration'

EXTRACT = {
    "python_command": "python -m include.Python.getSapData ALL false false false finance",
    "python_dir":     PYTHON_DIR,
}

DBT_JOBS = [
    {
        "name":        "teh_finance__dbt",
        "dbt_command": "teh_finance",
        "dbt_dir":     NEW_DBT_DIR,
    },
    {
        "name":        "old_finance__dbt",
        "dbt_command": "tag:finance",
        "dbt_dir":     OLD_DBT_DIR,
    },
    {
        "name":        "tea_service_fin__dbt",
        "dbt_command": "path:models/tea_service,tag:finance+",
        "dbt_dir":     NEW_DBT_DIR,
    },
    {
        "name":        "teh_revenue_cogs_fin__dbt",
        "dbt_command": "path:models/teh_revenue_cogs,tag:finance+",
        "dbt_dir":     NEW_DBT_DIR,
    }
]

# Hardcoded: this specific dbt job name triggers the python job on success
DBT_JOB_WITH_CHAIN = "teh_finance__dbt"

CHAINED_PYTHON_JOB = {
    "name":           "tb_load",
    "python_command": "python -m include.Python.oracle_tb_load <<COMPANY>> <<FISCAL_MONTH>> <<FISCAL_YEAR>> <<ENV>>",
    "python_dir":     PYTHON_DIR,
}



def get_log_path(step_name: str, index=None) -> Path:
    log_folder = Path(f"./Temp/logs/{DRIVER_NAME}/{CURRENT_TIMESTAMP}")
    log_folder.mkdir(parents=True, exist_ok=True)
    suffix = f"_{index}" if index is not None else ""
    return log_folder / f"{step_name}-{CURRENT_TIMESTAMP}{suffix}.log"




def run_python(python_dir: str, command: str, step_name: str, index=None) -> int:
    log_path     = get_log_path(step_name, index)
    full_command = rf"cd {Path(python_dir)}" + f" && {command}"

    with print_lock:
        print(f"\n>>> [{step_name}] starting")
        print(f"    {full_command}")

    with open(log_path, "a", encoding="utf-8") as f:
        f.write(f"Command  : {full_command}\n")
        f.write(f"Timestamp: {CURRENT_TIMESTAMP}\n")
        f.write("-" * 60 + "\n")
        f.flush()

        process = subprocess.Popen(
            full_command,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
        )
        for line in process.stdout:
            f.write(line)
            f.flush()
            with print_lock:
                print(line, end="")

        process.wait()
        f.write(f"\nReturn code: {process.returncode}\n")
        f.flush()

    with print_lock:
        print(f">>> [{step_name}] finished - rc={process.returncode}")

    return process.returncode


def run_dbt(job: dict) -> dict:
    """
    Runs a single dbt job.
    Returns the job dict with return_code added.
    """
    name         = job["name"]
    dbt_dir      = job["dbt_dir"]
    dbt_command  = job["dbt_command"]
    log_path     = get_log_path(name)
    full_command = rf"cd {Path(dbt_dir)}" + f" && dbt deps && dbt run --select {dbt_command}"

    with print_lock:
        print(f"\n>>> [{name}] starting")
        print(f"    {full_command}")

    with open(log_path, "w", encoding="utf-8") as f:
        f.write(f"Command  : {full_command}\n")
        f.write(f"Timestamp: {CURRENT_TIMESTAMP}\n")
        f.write("-" * 60 + "\n")
        f.flush()

        process = subprocess.Popen(
            full_command,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
        )
        for line in process.stdout:
            f.write(line)
            f.flush()
            with print_lock:
                print(line, end="")

        process.wait()
        f.write(f"\nReturn code: {process.returncode}\n")
        f.flush()

    with print_lock:
        print(f">>> [{name}] finished - rc={process.returncode}")

    return {**job, "return_code": process.returncode}


def step_extract() -> int:
    return run_python(
        python_dir=EXTRACT["python_dir"],
        command=EXTRACT["python_command"],
        step_name="python",
    )


def set_tb_load_params(py_command: str) -> str:
    now = datetime.datetime.now()
    
    if now.day > 10:
        return "python --version"
    fiscal_month = 12 if now.month == 1 else now.month - 1

    py_command = py_command.replace("<<COMPANY>>", "ALL")
    py_command = py_command.replace("<<FISCAL_MONTH>>", str(fiscal_month))
    py_command = py_command.replace("<<FISCAL_YEAR>>", now.strftime("%Y"))
    py_command = py_command.replace("<<ENV>>", ENV)
    return py_command


def step_dbt_parallel_with_chain() -> dict:
    """
    Fires all DBT_JOBS in parallel.
    When DBT_JOB_WITH_CHAIN finishes successfully, immediately
    triggers CHAINED_PYTHON_JOB (while other dbt jobs may still run).
    Waits for everything before returning.

    Returns results dict keyed by job name.
    """
    results       = {}
    python_future = None

    # n dbt workers + 1 slot reserved for the potential chained python job
    max_workers = len(DBT_JOBS) + 1

    with ThreadPoolExecutor(max_workers=max_workers) as pool:

        # futures_map = {
        #     pool.submit(run_dbt, job): job["name"]
        #     for job in DBT_JOBS
        # }
        futures_map = {}
        for job in DBT_JOBS:
            fut = pool.submit(run_dbt, job)
            futures_map[fut] = job["name"]
            time.sleep(120)

        for future in as_completed(futures_map):
            job_name = futures_map[future]
            result   = future.result()
            results[job_name] = result["return_code"]

            with print_lock:
                status = "OK" if result["return_code"] == 0 else "FAILED"
                print(f"\n  >> [{job_name}] completed - {status}")

            if job_name == DBT_JOB_WITH_CHAIN and datetime.datetime.now().hour < 8:
                with print_lock:
                    print(f"  >> [{job_name}] success - triggering: "
                            f"{CHAINED_PYTHON_JOB['name']}")
                    
                py_command = set_tb_load_params(CHAINED_PYTHON_JOB["python_command"])
                python_future = pool.submit(
                    run_python,
                    CHAINED_PYTHON_JOB["python_dir"],
                    py_command,
                    CHAINED_PYTHON_JOB["name"],
                )
                

        chained_name = CHAINED_PYTHON_JOB["name"]
        if python_future is not None:
            py_rc = python_future.result()
            results[chained_name] = py_rc
        else:
            results[chained_name] = None   # None = skipped

    return results


def send_failure_alert(stage: str, details: str):
    TT.sendEmail(
        "BI.Production-Alert-no-reply@us.tel.com",
        subject=f"{ENV}: Mini Orchestrator FAILED for: {DRIVER_NAME}: {CURRENT_TIMESTAMP}",
        email_content=(
            f"Team,\n\n"
            f"{DRIVER_NAME} failed at stage: {stage}\n\n"
            f"Details:\n{details}\n\n"
            f"Check logs at: //telusdwappprod/Shares/astro_datautility/Temp/logs/{DRIVER_NAME}\n\n\n"
            f"\n-mini_finance.py"
        ),
    )


def main():
    print(f"  {ENV}:{DRIVER_NAME} - {CURRENT_TIMESTAMP}")
    
    extract_rc = step_extract()

    if extract_rc != 0:
        print(f"\n!! Extract FAILED (rc={extract_rc}) - stopping.")
        send_failure_alert("Extract", f"python extract rc={extract_rc}")
        return

    print(f"\n  Extract SUCCESS")


    results = step_dbt_parallel_with_chain()


    failed = []
    for name, rc in results.items():
        if rc is None:
            status = "SKIPPED"
        elif rc == 0:
            status = "OK"
        else:
            status = "FAILED"
            failed.append(f"{name} (rc={rc})")
        print(f"{name}:::{status}")

    if failed:
        details = "\n".join(failed)
        print(f"\n!! Failures:\n{details}")
        send_failure_alert("Post-Extract", details)
    else:
        print(f"\n  All steps completed successfully.")


if __name__ == "__main__":
    main()