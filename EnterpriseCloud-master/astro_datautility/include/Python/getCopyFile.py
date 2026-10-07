import smbclient
import datetime
import os
import pandas as pd
import io
import include.Python.TELTools as TT
import json
import fnmatch
import sys
from uuid import uuid4

FILESHARE_URLS = {
    'PROD' : "172.26.95.44",
    'SIT': "NOCONFIG",
    'QA': "NOCONFIG",
    'DEV': "TELUSDWAPPDEV",
    'NOENVSET' : "TELUSDWAPPDEV"
}

RUN_TIME = datetime.datetime.now()
CURRENT_TIMESTAMP = str(RUN_TIME).replace(" ","_").replace(":","_").replace(".","_")
LZ_DB = os.environ["SNOWFLAKE_LZ"]

def _substitute_token(share_path):
    '''
        Substitute Token For Files which are picked up from Prod Box
    '''
    _Environment = os.getenv('ASTRO_DEPLOYMENT_NAME', 'NoEnvSet')
    print(f'Fetched Environment {_Environment}')

    if '<<FILE_SHARE>>' in share_path:
        if FILESHARE_URLS.get(_Environment.upper()) == 'NOCONFIG':
            return {
                "status": False,
                "message": f"URL for env {os.getenv('ASTRO_DEPLOYMENT_NAME')} is Under Development"
            }
        share_path = share_path.replace('<<FILE_SHARE>>', FILESHARE_URLS.get(_Environment.upper()))

    return {"status": True, "share_path": share_path}

def list_files_in_share(share_path, last_extraction_time, username, password,file_pattern, archive_files):
    """List files modified after the last extraction time in the given SMB share path."""
    try:
        print("Searching files start ...\n")
        smbclient.ClientConfig(username=username, password=password)

        files = []
        for file in smbclient.listdir(share_path):
            if archive_files and 'archives' in file:
                continue
            elif fnmatch.fnmatch(file.upper(),file_pattern.upper()):
                files.append((file, smbclient.stat(f"{share_path}\\{file}").st_mtime))
   
        new_files = [(file, datetime.datetime.fromtimestamp(mtime)) 
                    for file, mtime in files 
                    if datetime.datetime.fromtimestamp(mtime) > last_extraction_time]
        
        print(f"Searching files completed, {len(new_files)} files fetched...\n")
        return {"status": True, "message": f"Files listed successfully in share share_path","data": new_files}
    except Exception as e:
        print(f"Error listing files in share: , Error: {e}")
        return {"status": False, "message": f"Error listing files in share: share_path, Error: {e}", "data": []}

def move_files_to_archive(share_path, files, username, password):
    """ Move given files to 'archives' folder inside the SMB share path, appending a timestamp to each file. """
    try:
        print("Connecting to SMB share...\n")
        smbclient.ClientConfig(username=username, password=password)

        archive_path = os.path.join(f"{share_path}\\archives")

        if not smbclient.path.exists(archive_path):
            smbclient.mkdir(archive_path)
            print(f"Created 'archives' folder at {archive_path}")

        for file, file_dt in files:
            source = os.path.join(share_path, file)
            ts_str = file_dt.strftime("%Y%m%d_%H%M%S")
            base, ext = os.path.splitext(file)
            new_name = f"{base}_{ts_str}_{str(uuid4())}{ext}"
            destination = os.path.join(archive_path, new_name)

            if smbclient.path.exists(source):
                smbclient.rename(source, fr"\\{destination}")
                print(f"Moved {file} -> archives/{new_name}")
            else:
                print(f"File {file} not found in {share_path}, skipping...")

        return {"status": True, "message": "Files moved to archives with timestamps successfully."}

    except Exception as e:
        print(f"Error while moving files: {e}")
        return {"status": False, "message": f"Error moving files: {e}"}
    
def remove_files_from_share(file_path, username, password):
    """ Remove given files from the SMB share path. """
    try:
        print("Connecting to SMB share...\n")
        smbclient.ClientConfig(username=username, password=password)

        if smbclient.path.exists(file_path):
            smbclient.remove(file_path)
            print(f"Removed file: {file_path}")
        else:
            print(f"File {file_path} not found, skipping...")

        return {"status": True, "message": "Files removed successfully."}

    except Exception as e:
        print(e)
        return {"status": False, "message": f"Error removing files: {e}"}

def read_file_content(file_path, file_format = None):
    """Read the content of a file from the share using SMB Protocol."""
    if file_format == 'xlsx':
        read_mode = 'rb'
    else:
        read_mode = 'r'

    try:
        print("Enter read file content")
        with smbclient.open_file(file_path, mode=read_mode,encoding='utf-8') as file_obj:
            content = file_obj.read()
            return {"status": True, "message": f"File {file_path} read successfully", "data": content}
    except UnicodeDecodeError:
        with smbclient.open_file(file_path, mode=read_mode,encoding='cp932') as file_obj:
            content = file_obj.read()
            return {"status": True, "message": f"File {file_path} read successfully", "data": content}
    except Exception as e:
        return {"status": False, "message": f"Error reading file: {file_path}, Error: {str(e).encode('utf-8', errors='ignore')}", "data": None}   


def main(config_file,section):
    # Load configuration from JSON Config and validate the same
    config = TT.load_config(config_file)
    if config['data'] is None:
        print("Configuration could not be loaded. \n")
        raise Exception("Failed to load config")    
    selection = config['data'].get('CopyFile').get(section)

    if selection is None:
        raise Exception(f"Section '{section}' not found under CopyFile in config")

    is_active = selection.get('is_active', True)
    if isinstance(is_active, str):
        is_active = is_active.strip().lower() in ("true", "1", "yes", "y")
    elif isinstance(is_active, (int, float)):
        is_active = bool(is_active)

    if not is_active:
        print(f"WARNING: Dataset '{section}' is marked inactive in config (is_active={selection.get('is_active')}). Skipping processing.")
        return
    
    TT.validate_config(section,selection)

    token_sub = _substitute_token(selection.get('fileshare'))

    if not token_sub['status']:
        print("Configuration could not be loaded. \n")
        raise Exception(f"Failed to load config \n {token_sub['message']}")          
    
    share_path = token_sub.get('share_path')
    table = selection.get('table')
    schema = selection.get('schema')
    db = LZ_DB
    file_pattern =  selection.get('file_pattern') 
    securables = selection.get('securables')
    is_incremental = selection.get('is_incremental',False)
    delimiter = selection.get('delimiter')
    skip_header = selection.get('skip_header')
    ignore_header = selection.get('ignore_header')
    file_format = selection.get('file_format', None)
    archive_files = selection.get('archive_files', False)
    delete_after = selection.get('delete_after',False)
    header_row = selection.get('header_row',None)
    dtype = selection.get("force_str",None)
    convert_to_json = selection.get("convert_to_json",False)
    
    if securables:        
        password_name = securables.get('password-name') 
        username = securables.get('username')
        password = TT.getAzureSecret(password_name).value

    else:
        username = None  
        password = None
    
    if is_incremental:
        last_extraction_result = TT.read_runtime_config(db, schema)
        if last_extraction_result['data'] is None or last_extraction_result['status'] == False:
            raise Exception(f"Error while reading Runtime config: {last_extraction_result['message']}")    
        if last_extraction_result['status'] == True and last_extraction_result['data'].get(table) is None:
            last_extraction_time = '1990-01-01 00:00:00.000000'
        else:
            last_extraction_time = last_extraction_result["data"].get(table)
    else:
        last_extraction_time = '1990-01-01 00:00:00.000000'
    
    last_extraction_time = datetime.datetime.strptime(last_extraction_time, "%Y-%m-%d %H:%M:%S.%f")    
    print(f"Last extraction time for {table}: {last_extraction_time} \n")
    
    # Process the SMB share path
    #print(f"Listing files in: {share_path}")
    new_files_result = list_files_in_share(share_path, last_extraction_time, username, password,file_pattern,archive_files)
    
    if new_files_result['status'] == False:
        raise Exception(f"Error while fetching new_files_result : {new_files_result['message']}")

    if new_files_result['status'] == True and len(new_files_result['data']) == 0:
        print(f"No new files found after {last_extraction_time}, exiting successfully.")
        return

    new_files = new_files_result['data'] 
     
    row_count = 0
    for val in new_files:
        file = val[0]
        mod_time = val[1]
        
        file_path = f"{share_path}\\{file}"

        print(f'File to be processed {file}')
        read_file_content_results = read_file_content(file_path, file_format)
        
        if read_file_content_results['status'] == False:
            raise Exception(f"Error while read_file_content filename: {file} - mod_datetime: {mod_time}: {read_file_content_results['message']}")

        content = read_file_content_results['data']
        
        if content:
            print(f"Processing file: {file}")
            process_file_content_result = TT.process_file_content(
                content, file, last_extraction_time, db, schema, 
                table, delimiter, skip_header, ignore_header, section, 
                RUN_TIME, file_format=file_format, header_row = header_row, 
                dtype = dtype, convert_to_json = convert_to_json
            )
            row_count +=  process_file_content_result['data']
            
            if process_file_content_result['status'] == False:
                raise Exception(f"Error in process_file_content() : {process_file_content_result['message']}")

            if delete_after:
                _status = remove_files_from_share(file_path, username, password)

                if _status['status'] == False:
                    raise Exception(f"Error in remove_files_from_share() : {_status['message']}")

    if archive_files:
        _status = move_files_to_archive(share_path, new_files, username, password)

        if _status['status'] == False:
            raise Exception(f"Error in move_files_to_archive() : {_status['message']}")
                
    Extraction_End_Time = datetime.datetime.now()    
    if is_incremental:
        Incremental_End_Value = str(RUN_TIME)
    else :
        Incremental_End_Value = str(last_extraction_time)

    load_control_table_status= TT.load_control_table(
        CURRENT_TIMESTAMP=CURRENT_TIMESTAMP,
        Incremental_Start_Value=str(last_extraction_time),
        Incremental_End_Value=Incremental_End_Value,
        Extraction_Start_Time=str(RUN_TIME),
        Extraction_End_Time=str(Extraction_End_Time),
        table_name=table,
        MAX_FILE_DATE=str(RUN_TIME),
        rows_loaded=str(row_count),
        schema=schema,
        db=db
    )

    if load_control_table_status['status'] == False:
        raise Exception(f"Failed to update ControlTable: {load_control_table_status['message']}")

    print(f'\nProcess Complete for::: {section} ')

if __name__ == "__main__":
    args = sys.argv[1:]
    config_path = args[0]
    section = args[1]

    main(config_path,section)
