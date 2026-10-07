import datetime
import os
import pandas as pd
import io
import include.Python.TELTools as TT
import json
import fnmatch
import sys
import re
import paramiko


RUN_TIME = datetime.datetime.now()
CURRENT_TIMESTAMP = str(RUN_TIME).replace(" ","_").replace(":","_").replace(".","_")
LZ_DB = os.environ["SNOWFLAKE_LZ"]


def list_files_in_share(share_path, last_extraction_time, username, password, file_pattern, port=445):
    """List files modified after the last extraction time in the given share path."""
    try:
        print("Searching files start ...\n")
        path_parts = re.split('/|\\\\', share_path)
        path_parts = list(filter(None, path_parts))
        host = path_parts[0]
        dir = '/' + '/'.join(path_parts[1:])
        with paramiko.SSHClient() as ssh_client:
            ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh_client.connect(hostname=host, port=port, username=username, password=password)
            with ssh_client.open_sftp() as sftp:
                files = [
                    (file, mtime) 
                    for file in sftp.listdir(dir) 
                    if fnmatch.fnmatch(file, file_pattern) 
                        and datetime.datetime.fromtimestamp(mtime := sftp.stat(f"{dir}/{file}").st_mtime or 1e99) > last_extraction_time
                ]                
        print(f"Searching files completed, {len(files)} files fetched...\n")
        return {"status": True, "message": f"Files listed successfully in share share_path","data": files}
    except Exception as e:
        print(f"Error listing files in share: , Error: {e}")
        return {"status": False, "message": f"Error listing files in share: share_path, Error: {e}", "data": []}


def read_file_content(share_path, file, port=445, username=None, password=None):
    """Read the content of a file from the share using SMB Protocol."""
    try:
        file_path = f"{share_path}\\{file}"
        with paramiko.SSHClient() as ssh_client:
            path_parts = re.split('/|\\\\', share_path)
            path_parts = list(filter(None, path_parts))
            host = path_parts[0]
            dir = '/' + '/'.join(path_parts[1:])
            ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh_client.connect(hostname=host, port=port, username=username, password=password)
            with ssh_client.open_sftp() as sftp:
                with sftp.open(f"{dir}/{file}", 'r') as file_obj:
                    bytestring = str(file_obj.read())
                    content = eval(bytestring).decode()
                    return {"status": True, "message": f"File {file_path} read successfully", "data": content}
    except Exception as e:
        return {"status": False, "message": f"Error reading file: {file_path}, Error: {str(e).encode('utf-8', errors='ignore')}", "data": None}

def process_file_content(content, file_name, last_extraction_time, db, schema, table, delimiter, skip_header, ignore_header, section, RUN_TIME, dtype=None, file_format=None,load_as_json = False):
    """Convert content into a DataFrame and upload to Snowflake."""
    messages = []
    row_count = 0 
    print(load_as_json)   
    try:
        if file_format == 'xlsx':
            data_io = io.BytesIO(content) 
            df = pd.read_excel(data_io, dtype=dtype, engine='openpyxl')
        else:
            data_io = io.StringIO(content)  
            header = None if skip_header else 'infer'  
            df = pd.read_csv(data_io, delimiter=delimiter, header=header, dtype=dtype)

        if ignore_header and not load_as_json:
            df.columns = list(range(len(df.columns)))

        df = df.astype(str)
        df.replace('nan',None,inplace=True)
        
        if load_as_json:
            df = json.loads(df.to_json(orient='records'))
        
        if section.startswith('Prophet'): #aligning filename with existing process as parsed filename is used in dbt models
            file_name = f'{table}/{file_name}.gz'
       
        messages = TT.putSnowflakeDataFrame(
            db=db,
            schema=schema,
            tableName=table,
            df=df,
            fileName=file_name,
            fileDate=RUN_TIME
        )
        row_count = len(df)
        if "FAIL_SIGNAL" in messages:
            return {"status": False, "message": f"Error processing file content: {file_name} Error: {messages}", "data": row_count}
        else:
            print('Succesfully loaded in Snowflake')            
            return {"status": True, "message": f"{messages}", "data":row_count}
        
    except Exception as e:
        print(f"Error processing file content: {file_name}, Error: {e}")
        return {"status": False, "message": f"Error processing file content: {file_name} Error: {e}", "data": row_count}

def main(config_file,section):
    # Load configuration from JSON Config and validate the same
    config = TT.load_config(config_file)
    if config['data'] is None:
        print("Configuration could not be loaded. \n")
        raise Exception("Failed to load config")    
    selection = config['data'].get(section)
    
    TT.validate_config(section,selection)
    
    share_path = selection.get('fileshare')
    table = selection.get('table')
    schema = selection.get('schema')
    db = LZ_DB
    file_pattern =  selection.get('file_pattern') 
    securables = selection.get('securables')
    is_incremental = selection.get('is_incremental',False)
    delimiter = selection.get('delimiter')
    skip_header = selection.get('skip_header')
    ignore_header = selection.get('ignore_header')
    port = int(selection.get('port', 22))
    load_as_json = selection.get('load_as_json',False)
    file_format = selection.get('file_format','csv')
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
    new_files_result = list_files_in_share(share_path, last_extraction_time, username, password, file_pattern, port)
    
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

        print(f'File to be processed {file}')
        read_file_content_results = read_file_content(share_path, file, port, username, password)
        
        if read_file_content_results['status'] == False:
            raise Exception(f"Error while read_file_content filename: {file} - mod_datetime: {mod_time}: {read_file_content_results['message']}")
        
        content = read_file_content_results['data']
        
        if content:
            print(f"Processing file: {file}")
            process_file_content_result = process_file_content(content, file, last_extraction_time, db, schema, table,delimiter, skip_header, ignore_header, section, RUN_TIME, str,file_format,load_as_json)

            row_count +=  process_file_content_result['data']
            
            if  process_file_content_result['status'] == False:
                raise Exception(f"Error in process_file_content() : {process_file_content_result['message']}")
    
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
