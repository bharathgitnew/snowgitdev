import os
import sys
import json
import subprocess
import datetime
from pathlib import Path
import argparse

#sys.path.append(r'F:\Shares\astro_datautility\include\Python')
import include.Python.TELTools as TT

from concurrent.futures import ThreadPoolExecutor, as_completed
from threading import Lock
from typing import List, Dict, Any

api_call_datetimestamp = datetime.datetime.now()
CURRENT_TIMESTAMP = str(api_call_datetimestamp).replace(" ","_").replace(":","_").replace(".","_")

ProjectName = os.environ.get('snowflake_env')

PYTHON_DIR = r'F:\Shares\astro_datautility'
OLD_DBT_DIR = r'F:\Shares\astro_datautility\dags\dbt\dbt_project'
NEW_DBT_DIR = r'F:\Shares\astro_datautility\dags\dbt\dbt_tel'
CONFIG_DIR = r'F:\Shares\astro_datautility\include\Configuration'

CONFIG = {
    "DRIVER_QVICS_TROUBLE": {
        "python_command": "python -m include.Python.TelTools_SQLServer",
        "python_dir": PYTHON_DIR,
        "dbt_command": "tag:qvics_trouble --exclude pub.*",
        "dbt_dir": OLD_DBT_DIR,
        "config_path": f"{CONFIG_DIR}\\TelTools_SQLServer_QVICS-Trouble_Extract.json"
    },
    "DRIVER_QVICS": {
        "python_command": "python -m include.Python.TelTools_SQLServer",
        "python_dir": PYTHON_DIR,
        "dbt_command": "tag:qvics --exclude pub.*",
        "dbt_dir": OLD_DBT_DIR,
        "config_path": f"{CONFIG_DIR}\\TelTools_SQLServer_QVICS-NEW_Extract.json"
    },
    "DRIVER_ECC6": {
        "python_command": "python -m include.Python.getSapR3Data",
        "python_dir": PYTHON_DIR,
        "config_path": f"{CONFIG_DIR}\\TelTools_SapR3_InsertOverwrite_Mini_Orch.json"
    },
    "DRIVER_SAPAPI": {
        "python_command": "python -m include.Python.getSapData ALL false false false daily",
        "python_dir": PYTHON_DIR,
        "dbt_command": "tag:sapapi+ common.reports common.shared_datasets --exclude common.reports_fin01 common.de_sales_operations tag:finance tag:first_of_month pub.*",
        "dbt_dir": OLD_DBT_DIR
    },
    "DRIVER_WISDOM": {
        "python_command": "python -m include.Python.TelTools_Oracle",
        "python_dir": PYTHON_DIR,
        "dbt_command": "tag:wisdom common.de_wisdom --exclude pub.*",
        "dbt_dir": OLD_DBT_DIR,
        "config_path": f"{CONFIG_DIR}\\TelTools_Oracle_Wisdom_Extract.json"
    },
    "DRIVER_TELCUSTOMER": {
        "python_command": "python -m include.Python.TelTools_SQLServer",
        "python_dir": PYTHON_DIR,
        "dbt_command": "tag:telcustomer --exclude pub.*",
        "dbt_dir": OLD_DBT_DIR,
        "config_path": f"{CONFIG_DIR}\\TelTools_SQLServer_TELCUSTOMER-MINI_Extract.json"
    },
    "DRIVER_TMEA_AZURE_DEVOPS": {
        "python_command": "python -m include.Python.getWorkItemDetails",
        "python_dir": PYTHON_DIR
    },
    "DRIVER_DISA": {
        "python_command": f"python -m include.Python.getCopyFile {CONFIG_DIR}\\TelTools_CopyFile_DISA.json FILE-ZCSV_T_SDT",
        "python_dir": PYTHON_DIR
    },
    "DRIVER_ADO_MONDAY": {
        "python_command": f"python -m include.Python.runDevOpsSfMonday",
        "python_dir": PYTHON_DIR
    }

}


def run_dbt(project_dir,driver_name,model_name):

    log_folder = Path(f"./Temp/logs/{driver_name}/{CURRENT_TIMESTAMP}")
    log_folder.mkdir(parents=True, exist_ok=True)
    log_path = log_folder / f'dbt_{driver_name}_{CURRENT_TIMESTAMP}.log'
    _command_to_run = rf"cd {Path(project_dir)}" + f" && dbt deps && dbt run --select {model_name}"
    print(_command_to_run)
    with open(log_path, 'w',encoding = 'utf-8') as f:
        f.write(_command_to_run)
        f.flush()
        process = subprocess.Popen(
            _command_to_run,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1
        )

        for line in process.stdout:
            f.write(line)
            print(line, end="")
            f.flush()

        process.wait()
        return process.returncode

def run_python(project_dir,driver_name,command, index_logs = False):

    if not index_logs:
        log_folder = Path(f"./Temp/logs/{driver_name}/{CURRENT_TIMESTAMP}")
        log_folder.mkdir(parents=True, exist_ok=True)
        log_path = log_folder / f'python_{driver_name}_{CURRENT_TIMESTAMP}.log'
        _command_to_run = rf"cd {Path(project_dir)}" + f" && {command}"
        print(_command_to_run)
        with open(log_path, 'a',encoding = 'utf-8') as f:

            process = subprocess.Popen(
                _command_to_run,
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1
            )

            for line in process.stdout:
                f.write(line)
                print(line, end="")
                f.flush()
            process.wait()
            return process.returncode
    else:
        log_folder = Path(f"./Temp/logs/{driver_name}/{CURRENT_TIMESTAMP}")
        log_folder.mkdir(parents=True, exist_ok=True)
        log_path = log_folder / f'python_{driver_name}_{CURRENT_TIMESTAMP}_{index_logs}.log'
        _command_to_run = rf"cd {Path(project_dir)}" + f" && {command}"
        print(_command_to_run)
        with open(log_path, 'a',encoding = 'utf-8') as f:
            process = subprocess.Popen(
                _command_to_run,
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1
            )

            for line in process.stdout:
                f.write(line)
                print(line, end="")
                f.flush()
            process.wait()
            return process.returncode


def command_list_SQL(config_file_path):
    with open(config_file_path) as f:
        cfg=json.load(f)
        commands = [
            f'{config_file_path} {ds["table"]}'
            for group in cfg.values()
            for ds in group.values()
            ]
        return commands

def command_ecc6_list(config_file_path):
    with open(config_file_path) as f:
        cfg=json.load(f).get("extraction")
        commands = [
            f'--config-file {config_file_path} --extraction-name {key} --env PROD --chunk-size {ds["chunk_size"]} --debug False'
            for key, ds in cfg.items()
        ]
        return commands

def command_list_CopyFile(config_file_path):
    with open(config_file_path) as f:
        cfg=json.load(f)
        commands = [
            f'{config_file_path} {ds}'
            for ds, _ in cfg["CopyFile"].items()
            ]
        return commands

def all_success(codes):
    return len(codes) > 0 and all(rc == 0 for rc in codes)

def run_commands_threaded_submit(
    py_commands: List[str],
    _config: Dict[str, Any],
    driver_name: str,
    max_workers: int = 4,
) -> List[Dict[str, Any]]:

    print_lock = Lock()

    def _run_one(command: str, idx : int):
        with print_lock:
            print(command)
        try:
            rc = run_python(
                _config["python_dir"],
                driver_name,
                f'{_config["python_command"]} {command}',
                index_logs=idx
            )
            return rc
        except Exception:
            with print_lock:
                print("Py Fail")
            return 1

    futures = []
    with ThreadPoolExecutor(max_workers=max_workers) as pool:
        for idx, cmd in enumerate(py_commands):
            fut = pool.submit(_run_one, cmd, idx)
            futures.append((idx, cmd, fut))

        results = [None] * len(futures)
        for idx, cmd, fut in futures:
            rc = fut.result()
            results[idx] = {"command": cmd, "return_code": rc}

    return results

def main(driver_name: str):
    try:
        _config = CONFIG.get(driver_name)
        dbt_op = None

        if driver_name in ['DRIVER_SAPAPI','DRIVER_FINANCE','DRIVER_KRONOS','DRIVER_FILE_1','DRIVER_WORKDAY_1','DRIVER_WORKDAY_2','DRIVER_ADO_MONDAY','DRIVER_TEA_GCE_OPERATIONS_4','DRIVER_TMEA_AZURE_DEVOPS','DRIVER_DISA','DRIVER_TEA_INTEL_SMS','DRIVER_GMX','DRIVER_GMX_ONDEMAND','DRIVER_GMX_QUEUE','DRIVER_GMX_ONDEMAND_QUEUE','DRIVER_FINANCE_TAGS_OLD_ARCH']:
            py_return_codes = []
            try:
                py_op = run_python(_config["python_dir"],driver_name,_config["python_command"])
            except Exception as e:
                py_op = 1
                print("Py Fail")
            print(py_op)
            py_return_codes.append(py_op)

            if all_success(py_return_codes):
                if _config.get("dbt_dir"):
                    dbt_op = run_dbt(_config.get("dbt_dir"),driver_name,_config["dbt_command"])

        elif driver_name in ['DRIVER_WISDOM','DRIVER_TELCUSTOMER']:
            py_commands = command_list_SQL(_config["config_path"])
            results = run_commands_threaded_submit(py_commands, _config, driver_name, max_workers=8)
            py_return_codes = []
            log_folder = Path(f"./Temp/logs/{driver_name}/{CURRENT_TIMESTAMP}")
            log_folder.mkdir(parents=True, exist_ok=True)
            log_path = log_folder / f'python_{driver_name}_{CURRENT_TIMESTAMP}.log'

            with open(log_path, 'a',encoding = 'utf-8') as f:
                for value in results:
                    py_return_codes.append(value["return_code"])
                    f.write(f'command : {value["command"]} and {value["return_code"]} \n')
                    f.flush()

            if all_success(py_return_codes):
                dbt_op = run_dbt(_config["dbt_dir"],driver_name,_config["dbt_command"])

        elif driver_name in ['DRIVER_ECC6']:
            py_commands = command_ecc6_list(_config["config_path"])
            results = run_commands_threaded_submit(py_commands, _config, driver_name, max_workers=6)
            py_return_codes = []
            log_folder = Path(f"./Temp/logs/{driver_name}/{CURRENT_TIMESTAMP}")
            log_folder.mkdir(parents=True, exist_ok=True)
            log_path = log_folder / f'python_{driver_name}_{CURRENT_TIMESTAMP}.log'

            with open(log_path, 'a',encoding = 'utf-8') as f:
                for value in results:
                    py_return_codes.append(value["return_code"])
                    f.write(f'command : {value["command"]} and {value["return_code"]} \n')
                    f.flush()

            if all_success(py_return_codes):
                pass

        else :
            py_commands = command_list_SQL(_config["config_path"])
            if driver_name in ['DRIVER_PROPHET','DRIVER_FILE_2','DRIVER_TEA_THREEPL_OPERATIONS_2','DRIVER_TEA_GCE_OPERATIONS_1']:
                py_commands = command_list_CopyFile(_config["config_path"])
            py_return_codes = []
            for command in py_commands:
                print(command)
                try:
                    py_op = run_python(_config["python_dir"],driver_name,f'{_config["python_command"]} {command}')
                except Exception as e:
                    py_op = 1
                    print("Py Fail")
                py_return_codes.append(py_op)

            if all_success(py_return_codes):
                dbt_op = run_dbt(_config["dbt_dir"],driver_name,_config["dbt_command"])


        py_success = all_success(py_return_codes)
        dbt_failed = (dbt_op is not None and dbt_op != 0)

        if (not py_success) or dbt_failed:
            ...
            TT.sendEmail(
                        "BI.Production-Alert-no-reply@us.tel.com",
                        subject=f"Mini Orchestrator FAILED for: {driver_name}: {CURRENT_TIMESTAMP}",
                        email_content=(
                            f"Team,\n\n"
                            f"{driver_name} failed!\n\n"
                            f"python_status: {py_return_codes} , dbt_status:{dbt_op}\n\n"
                            f"Check logs at: //telusdwappprod/Shares/astro_datautility/Temp/logs/{driver_name}\n\n\n"
                            f"-mini.py"
                        ),
                    )
    except Exception as e:
        TT.sendEmail(
                        'BI.Production-Alert-no-reply@us.tel.com',
                        subject =f'Mini Orchestrator FAILED for: {driver_name}: {CURRENT_TIMESTAMP}',
                        email_content=f'''Team,\n{driver_name} failed,
                        {str(e)}
                        '''
                        )
        raise Exception(f"Failed: {str(e)}")






if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--driver_name", required=True)
    args = parser.parse_args()
    main(args.driver_name)






