import logging

# suppress Box SDK HTTP noise
logging.getLogger("boxsdk").setLevel(logging.WARNING)
logging.getLogger("urllib3").setLevel(logging.WARNING)



import os
import sys
import json
from io import BytesIO
from pathlib import Path
from ast import literal_eval
from datetime import datetime
from fnmatch import fnmatch
from functools import singledispatch
from concurrent.futures import ThreadPoolExecutor, as_completed
from boxsdk import (
    Client, JWTAuth
)
from include.Python.TELTools import (
    getAzureSecret, 
    process_file_content,
    readControlTable,
    load_control_table
)
from azure.core.exceptions import (
    ResourceNotFoundError,
    HttpResponseError
)

RUN_TIME = datetime.now()
CURRENT_TIMESTAMP = str(RUN_TIME).replace(" ","_").replace(":","_").replace(".","_")

@singledispatch
def _serialize(value):
    raise TypeError(f"Unsupported type: {type(value)}")

@_serialize.register(str)
def _(value) :
    try:
        dt = datetime.fromisoformat(value)
    except ValueError:
        dt = datetime.strptime(value, "%Y-%m-%d %H:%M:%S")
    
    return dt.replace(tzinfo=None, microsecond=0)

@_serialize.register(datetime)
def _(value):
    dt = value.replace(tzinfo=None, microsecond=0)
    return dt.strftime("%Y-%m-%d %H:%M:%S")

def _collect_active_configurations(_all_configurations):
    return {
        k: v
        for k, v in _all_configurations.get("extraction").items()
        if v.get("is_active")
    }

def _open_configurations(config_file_name):
    return json.loads(
        Path(config_file_name).read_text()
    )

def _format_rsa_private_key(value):
    return (
        "-----BEGIN ENCRYPTED PRIVATE KEY-----"
        + value.replace("\\n", "\n")
        + "-----END ENCRYPTED PRIVATE KEY-----\n"
    )

def _get_connection_client(all_configurations):

    _connection = {}
    
    if not all_configurations.get('connection', False):
        raise ConnectionRefusedError(f'Need the Key "connection" while trying to build client : {e}')

    for connection_item, connection_value in all_configurations.get('connection').items():
        if connection_item.lower() == "auth":
            continue
        try:
            _connection[connection_item] = getAzureSecret(connection_value).value
        except (ResourceNotFoundError,HttpResponseError):
            _connection[connection_item] = connection_value
        except Exception as e:
            raise ConnectionRefusedError(f'Problem while fetching Secrets from Azure Key Vault : {e}')
 
    if (_auth := all_configurations.get('connection').get('auth', '').upper()) == 'JWT':
        try:
            auth_connections = JWTAuth(
                **{
                    k: _format_rsa_private_key(v) if k == "rsa_private_key_data" and isinstance(v, str) else v
                    for k, v in _connection.items()
                }
            )
            _connection = '#MASKED#'
            client = Client(auth_connections)
            current_user = client.user().get()
            auth_connections = '#MASKED#'
            print(f'Sucessfully Authenticated to user : {current_user.name} using auth-mode : {_auth}')

        except Exception as e:
            raise ConnectionRefusedError(f'Failed to Authenticate User credentials using auth-mode {_auth} : {e}')

    else:
        # Placeholder for other type of authentcations.
        ...

    return client

def _is_allowed_file_type(file_name, configured_type):
    if not configured_type:
        return False
    expected_extension = f".{str(configured_type).lower().lstrip('.')}"
    return Path(file_name).suffix.lower() == expected_extension


def _parse_match_patterns(raw_patterns):
    if raw_patterns is None:
        return []

    if isinstance(raw_patterns, str):
        return [pattern.strip() for pattern in raw_patterns.split("|") if pattern.strip()]

    if isinstance(raw_patterns, (list, tuple, set)):
        patterns = []
        for pattern in raw_patterns:
            if isinstance(pattern, str) and pattern.strip():
                patterns.append(pattern.strip())
        return patterns

    return []


def _matches_any_pattern(file_name, raw_patterns):
    file_name_lower = str(file_name).lower()
    patterns = _parse_match_patterns(raw_patterns)

    if not patterns:
        return False

    return any(fnmatch(file_name_lower, pattern.lower()) for pattern in patterns)


def _resolve_worker_count(parameters_for_current):
    _threading = parameters_for_current.get("threading") or {}
    if not _threading.get("enabled"):
        return 1
    try:
        _workers = int(_threading.get("max_workers", 4))
    except (TypeError, ValueError):
        _workers = 4
    return max(1, _workers)


def _resolve_last_extraction_time(parameters_for_current, control_table_entry):
    _is_incremental = parameters_for_current.get("is_incremental", True)
    if _is_incremental and control_table_entry:
        return _is_incremental, _serialize(control_table_entry)
    return _is_incremental, _serialize('1990-01-01 00:00:00.000000')


def _ingest(*, dataset_name, dataset_config, parameters_for_current, memory_buffer, file_info):
    
    sheet_name = parameters_for_current.get("sheet_name", None)
    _file_type = parameters_for_current.get("type_of_file")

    try:

        _file_upload_status = process_file_content(
            content = memory_buffer,
            file_name = f'{file_info.name}',
            file_format = _file_type,
            sheet_name = sheet_name,
            last_extraction_time = '1990-01-01 00:00:00.000000',
            db = os.environ["SNOWFLAKE_LZ"],
            RUN_TIME = RUN_TIME,
            section = 'ups',
            **dataset_config.get('destination'),
            **parameters_for_current.get('pandas_engine')
        )

        if not _file_upload_status.get("status") and sheet_name is not None:
            print(
                f"Warning: Could not process sheet '{sheet_name}' in '{file_info.name}'. "
                f"Retrying with sheet index 0 (first sheet)."
            )
            memory_buffer.seek(0)
            _file_upload_status = process_file_content(
                content = memory_buffer,
                file_name = f'{file_info.name}',
                file_format = _file_type,
                sheet_name = 0,
                last_extraction_time = '1990-01-01 00:00:00.000000',
                db = os.environ["SNOWFLAKE_LZ"],
                RUN_TIME = RUN_TIME,
                section = 'ups',
                **dataset_config.get('destination'),
                **parameters_for_current.get('pandas_engine')
            )

        _file_upload_status["dataset"] = dataset_name

    except Exception as e:
        return {
            "status": False,
            "message": f"Error processing file content: {file_info.name} Error: {e}"
        }
    
    return _file_upload_status


def _process_one_file(*, client, file_id, dataset_name, dataset_config, parameters_for_current, file_type, last_extraction_time, is_incremental):

    _file_label = file_id

    try:
        file_info = client.file(file_id).get()
        _file_label = file_info.name

        if not _is_allowed_file_type(file_info.name, file_type):
            print(f"Skipping (extension mismatch): {file_info.name}")
            return {
                "status": True,
                "dataset": dataset_name,
                "message": (
                    f"['Skipped file due to extension mismatch: {file_info.name}. "
                    f"Expected .{file_type.lstrip('.')}, got {Path(file_info.name).suffix or 'no extension'}']"
                ),
                "data": 0,
                "_file_date": None,
                "_append": True
            }

        _current_file_date = _serialize(file_info.modified_at)

        if not is_incremental or _current_file_date > last_extraction_time:
            print(f"Downloading and ingesting: {file_info.name} (modified: {_current_file_date})")
            memory_buffer = BytesIO()
            client.file(file_id).download_to(memory_buffer)
            memory_buffer.seek(0)
            _file_upload_status = _ingest(
                dataset_name=dataset_name,
                dataset_config=dataset_config,
                parameters_for_current=parameters_for_current,
                memory_buffer=memory_buffer,
                file_info=file_info
            )
            _file_upload_status["_file_date"] = _current_file_date
            _file_upload_status["_append"] = True
            return _file_upload_status

        print(f"No new changes: {file_info.name} (modified: {_current_file_date})")
        return {
            "status": True,
            "message": f"['No New changes in File : {file_info.name} Incremental Date: \"{_current_file_date}\"']",
            "data": 0,
            "_file_date": None,
            "_append": False
        }

    except Exception as e:
        return {
            "status": False,
            "message": f"Error processing file content: {_file_label} Error: {e}",
            "_file_date": None,
            "_append": True
        }


def _ingest_files(*, client, required_items, dataset_name, dataset_config, parameters_for_current, file_type, last_extraction_time, is_incremental, worker_count):

    _results = []

    if worker_count <= 1:
        print(f"Ingesting {len(required_items)} file(s) in single-threaded mode")
        for _file_id, _file_name_match in required_items:
            _result = _process_one_file(
                client=client,
                file_id=_file_id,
                dataset_name=dataset_name,
                dataset_config=dataset_config,
                parameters_for_current=parameters_for_current,
                file_type=file_type,
                last_extraction_time=last_extraction_time,
                is_incremental=is_incremental
            )
            print(f"Completed: {_file_name_match} -> {'OK' if _result.get('status') else 'FAILED'}")
            _results.append(_result)
    else:
        print(f"Ingesting {len(required_items)} file(s) using {worker_count} worker thread(s)")
        with ThreadPoolExecutor(max_workers=worker_count) as executor:
            _future_to_name = {
                executor.submit(
                    _process_one_file,
                    client=client,
                    file_id=_file_id,
                    dataset_name=dataset_name,
                    dataset_config=dataset_config,
                    parameters_for_current=parameters_for_current,
                    file_type=file_type,
                    last_extraction_time=last_extraction_time,
                    is_incremental=is_incremental
                ): _file_name_match
                for _file_id, _file_name_match in required_items
            }

            for _future in as_completed(_future_to_name):
                _file_name_match = _future_to_name[_future]
                try:
                    _result = _future.result()
                except Exception as e:
                    _result = {
                        "status": False,
                        "message": f"Error processing file content: {_file_name_match} Error: {e}",
                        "_file_date": None,
                        "_append": True
                    }
                print(f"Completed: {_file_name_match} -> {'OK' if _result.get('status') else 'FAILED'}")
                _results.append(_result)

    print(
        f"Ingestion complete for {dataset_name}: "
        f"{len(_results)} file(s) | "
        f"success: {sum(1 for r in _results if r.get('status'))} | "
        f"failed: {sum(1 for r in _results if not r.get('status'))}"
    )

    return _results


def main(config_file_name):

    _all_configurations = _open_configurations(config_file_name)
    _client = _get_connection_client(_all_configurations)
    _status = []

    for dataset_name, dataset_config in _collect_active_configurations(_all_configurations).items():
    
        print(f"\n{'='*60}")
        print(f"###    Started Extraction of {dataset_name}    ###")
        print(f"{'='*60}\n")
        
        parameters_for_current = dataset_config.get('parameters')
        dataset_max_file_date = None
        dataset_rows_loaded = 0
        dataset_has_failed_ingestion = False

        if (_file_type := parameters_for_current.get('type_of_file')) == 'xlsx':
            if not (
                (_file_id := parameters_for_current.get('file_id')) or
                (_folder_id := parameters_for_current.get('folder_id'))
            ):
                raise ConnectionAbortedError(f'Needed parameter "folder_id" and/or "file_id" for {_file_type}')
            
            if sheet_name := parameters_for_current.get('sheet_name', None):
                print(f'Ingesting Sheet for File {sheet_name}')
        
            control_table_entry, function_messages = readControlTable(
                db = os.environ["SNOWFLAKE_LZ"],
                schema = dataset_config.get('destination').get('schema'),
                table_name = dataset_config.get('destination').get('table') 
            )

            _is_incremental, last_extraction_time = _resolve_last_extraction_time(parameters_for_current, control_table_entry)

            print(f"Ingestion Mode: {'INCREMENTAL' if _is_incremental else 'FULL (is_incremental=false)'}")
            print(
                f"Incremental Start Date: "
                f"{last_extraction_time.strftime('%Y-%m-%d %H:%M:%S') if isinstance(last_extraction_time, datetime) else last_extraction_time}"
            )

            if _file_id:
                try:        
                    file_info = _client.file(_file_id).get()

                    if not _is_allowed_file_type(file_info.name, _file_type):
                        _status.append(
                            {
                                "status": True,
                                "dataset": dataset_name,
                                "message": (
                                    f"['Skipped file due to extension mismatch: {file_info.name}. "
                                    f"Expected .{_file_type.lstrip('.')}, got {Path(file_info.name).suffix or 'no extension'}']"
                                ),
                                "data": 0
                            }
                        )
                        continue

                    _current_file_date = _serialize(file_info.modified_at)

                    if not _is_incremental or _current_file_date > last_extraction_time:
                        memory_buffer = BytesIO()
                        _client.file(_file_id).download_to(memory_buffer)
                        memory_buffer.seek(0)
                        _status.append(
                            _ingest(
                                dataset_name=dataset_name,
                                dataset_config=dataset_config,
                                parameters_for_current=parameters_for_current,
                                memory_buffer=memory_buffer,
                                file_info=file_info
                            )
                        )
                        _latest_status = _status[-1]
                        if _latest_status.get("status"):
                            dataset_rows_loaded += int(_latest_status.get("data", 0) or 0)
                            dataset_max_file_date = (
                                _current_file_date
                                if dataset_max_file_date is None
                                else max(dataset_max_file_date, _current_file_date)
                            )
                        else:
                            dataset_has_failed_ingestion = True
                    else:
                        _status.append(
                            {
                                "status": True,
                                "message": f"['No New changes in File : {file_info.name} Sheet Name: \"{sheet_name}\" Incremental Date: \"{_current_file_date}\"']",
                                "data": 0
                            } 
                        )
                        continue

                except Exception as e :
                    _status.append(
                        {
                            "status": False, 
                            "message": f"Error processing file content: {file_info.name} Error: {e}"
                        }
                    )
                    dataset_has_failed_ingestion = True
                    continue

            elif _folder_id:
                try:

                    folder = _client.folder(_folder_id.get('id'))

                    folder_info = folder.get(fields=["name", "size", "created_at", "modified_at", "owned_by"])
                    print(f"Current Folder information :")
                    print(f"Name: {folder_info.name}")
                    print(f"Size: {folder_info.size} bytes")
                    print(f"Created: {folder_info.created_at}")
                    print(f"Modified: {folder_info.modified_at}")
                    print(f"Owner: {folder_info.owned_by['name']}")
                    print("\n")

                    _all_folder_items = [
                        (item.id, item.name)
                        for item in folder.get_items(fields=["id", "name"])
                    ]

                    _required_items = [
                        oneitem
                        for oneitem in _all_folder_items
                        if _matches_any_pattern(oneitem[-1], _folder_id.get('matches'))
                    ]

                    _worker_count = _resolve_worker_count(parameters_for_current)
                    print(f"Matched {len(_required_items)} file(s) for ingestion in folder '{folder_info.name}'")

                    for _result in _ingest_files(
                        client=_client,
                        required_items=_required_items,
                        dataset_name=dataset_name,
                        dataset_config=dataset_config,
                        parameters_for_current=parameters_for_current,
                        file_type=_file_type,
                        last_extraction_time=last_extraction_time,
                        is_incremental=_is_incremental,
                        worker_count=_worker_count
                    ):
                        _file_date = _result.pop("_file_date", None)
                        if not _result.pop("_append", True):
                            continue
                        _status.append(_result)
                        if _result.get("status"):
                            dataset_rows_loaded += int(_result.get("data", 0) or 0)
                            if _file_date is not None:
                                dataset_max_file_date = (
                                    _file_date
                                    if dataset_max_file_date is None
                                    else max(dataset_max_file_date, _file_date)
                                )
                        else:
                            dataset_has_failed_ingestion = True

                except Exception as e :
                    _status.append(
                        {
                            "status": False, 
                            "message": f"Error processing folder content: {_folder_id.get('id')} Error: {e}"
                        }
                    )
                    dataset_has_failed_ingestion = True
                    continue

            if dataset_max_file_date is not None and not dataset_has_failed_ingestion:
                _load_control_table_status = load_control_table(
                    CURRENT_TIMESTAMP=CURRENT_TIMESTAMP,
                    Incremental_Start_Value=_serialize(last_extraction_time),
                    Incremental_End_Value=_serialize(dataset_max_file_date),
                    Extraction_Start_Time=_serialize(RUN_TIME),
                    Extraction_End_Time=_serialize(datetime.now()),
                    MAX_FILE_DATE=_serialize(dataset_max_file_date),
                    rows_loaded=str(dataset_rows_loaded),
                    db=os.environ["SNOWFLAKE_LZ"],
                    schema=dataset_config.get('destination').get('schema'),
                    table_name=dataset_config.get('destination').get('table')
                )
                if _load_control_table_status.get("status") is False:
                    _status.append(
                        {
                            "status": False,
                            "dataset": dataset_name,
                            "message": f"Failed to update ControlTable: {_load_control_table_status.get('message')}"
                        }
                    )
            
        else:
            ...
                #placeholder for other type of file

    _fail_extraction = False

    for one_status in _status:

        if not one_status.get("status"):
            _pretty = (
                f"\nError Encountered\n" +
                one_status.get("message") 
                + "\n"
            )
            print(_pretty)
            _fail_extraction = True
        
        else:
            _pretty = (
                f"\nExecution logs for {one_status.get('dataset', 'Files')}\n"+
                "".join(f"[{index}] {log}\n" for index , log in enumerate(literal_eval(one_status.get("message")),1))+
                f"Number of Rows Processed : {one_status.get('data')}"
            )
            print(_pretty)

    if _fail_extraction:
        raise Exception("Data Extraction Failed for One or more Datasets. Please check Logs")
    

if __name__ == "__main__":
    all_arguments = sys.argv[1:]
    config_path = all_arguments[0]
    main(config_path)