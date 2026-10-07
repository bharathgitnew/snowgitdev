
# imports
import pandas as pd
import numpy as np
import os, sys, json, gc, sqlalchemy, re, csv, math
from datetime import datetime, timedelta
import include.Python.TELTools as TT
from concurrent.futures import ThreadPoolExecutor
import threading
from azure.storage.blob import BlobClient, ContainerClient
import io, gzip
from itertools import repeat
import warnings
import glob


# globals
batch_datetimestamp = datetime.now()
CURRENT_TIMESTAMP = str(datetime.now()).replace(" ","_").replace(":","_").replace(".","_")
tel_tools_config_path = '/usr/local/airflow/include/Configuration/TELTools.json'
# LastDefaultRun_path = "F:\\Shares\\Files\\TokyoElectron\\Python\\RuntimeConfig\\crm_file\\crm.LastDefaultRun.json"
LZ_DB = os.environ["SNOWFLAKE_LZ"]
LZ_SCHEMA = 'CRM_FILE'
ENV = os.environ['SNOWFLAKE_ENV']
MODEL_JSON_TABLE_NAME = 'MODEL_JSON'
SCHEMA_CSV_TABLE_NAME = 'SCHEMA_TABLE'

# K 39050 : Task to Remove blob Stroage dependency on Scripts using it.
# 1. Model.json was being uploaded to blob, Have created a tabled in snowflake which stores model.json (TABLE NAME : MODEL_JSON)
# 2. Schema.csv was being  uploaded to blob, Have created a tabled in snowflake which stores schema.csv (TABLE NAME : SCHEMA_TABLE)
# 3. commented all code related to blob and have necessary changes to it.


# MANIFEST_PATH = 'MANIFEST/'
# if ENV != 'PROD':
#     MANIFEST_PATH = ENV+'/'+MANIFEST_PATH

dtype_conversions = {
    'boolean': 'BOOLEAN', 
    'datetime': 'TIMESTAMP_LTZ(9)', 
    'datetimeoffset': 'TIMESTAMP_LTZ(9)', 
    'decimal': 'NUMBER(38,10)', 
    'double': 'NUMBER(38,10)', 
    'guid': 'VARCHAR(16777216)', 
    'int64': 'NUMBER(38,0)', 
    'string': 'VARCHAR(16777216)'
}

default_file_format = {
    'columnHeaders': False,
    'delimiter': ',',
    'quoteStyle': 'QuoteStyle.Csv',
    'csvStyle': 'CsvStyle.QuoteAlways',
    'encoding': 'UTF-8'
}

quote_styles = {
    'CsvStyle.QuoteAlways': csv.QUOTE_ALL, 
    'CsvStyle.QuoteAfterDelimiter': csv.QUOTE_ALL # will need to look deeper into potential quote styles
}

master_model_json = {}

metadata_config = {}

for i in range(math.ceil(math.log10(sys.maxsize))):
    try:
        csv.field_size_limit(int(sys.maxsize/(10**i)))
        break
    except:
        continue


def is_locked(entity_name,RUN_FILE):
    return os.path.exists(os.path.join(RUN_FILE, f"{entity_name}.lock"))

def lock(entity_name,RUN_FILE):
    open(os.path.join(RUN_FILE, f"{entity_name}.lock"), 'w').close()

def unlock(entity_name,RUN_FILE):
    print(f"Unlocking {entity_name}")
    os.remove(os.path.join(RUN_FILE, f"{entity_name}.lock"))

# load config entries from TELTools.json
def getTELToolsConfig():
    with open(tel_tools_config_path,'r') as f:
        tel_tools_json = json.load(f,strict=False)
        crm_json = tel_tools_json.get('Services').get('CRM').get(ENV)
        FILEUPLOADER_CONFIG = crm_json.get('FILEUPLOADER_CONFIG')
        THREADS = int(crm_json.get('THREADS'))
        # get last incremental value (date from last run) - store in file in runtime config folder 
        RUN_FILE = crm_json.get('RUN_FILE')
    return FILEUPLOADER_CONFIG, THREADS, RUN_FILE


def readRuntimeConfig(table_name):
    messages = []
    db = LZ_DB
    schema = LZ_SCHEMA
    conn, messages = TT.getSnowFlakeConn(db, schema, messages)
    if conn != "no connection":
        try:
            cur = conn.cursor()
            if table_name == "LastDefaultRun": #to get the last default run value
                query="select INCREMENTAL_END_VALUE from "+db+"."+schema+".CONTROLTABLE WHERE TABLE_NAME='"+table_name+"' order by RUN_TIME desc limit 1"
            else: #get the table run value
                query="select INCREMENTAL_END_VALUE from "+db+"."+schema+".CONTROLTABLE WHERE TABLE_NAME='"+table_name+"' order by RUN_TIME desc"

            cur.execute(query)
            results = cur.fetchall()
            data = [i[0] for i in results]
            messages.append(
                f"readControlTable(): Read from snowflake completed for {db}, {schema}, CONTROLTABLE- {data}"
            )
            conn.close()
            return data, messages
        except Exception as e:
            print(f"Error reading from snowflake: ,{table_name}")
            print(e)
            messages.append(f"FAIL_SIGNAL")
            messages.append(
                f"Read Data: Read from snowflake failed for {db}, {schema}, {table_name}: {e}"
            )
            conn.close()
            return None, messages


def load_control_table(
    CURRENT_TIMESTAMP,
    Incremental_Start_Value,
    Incremental_End_Value,
    Extraction_Start_Time,
    Extraction_End_Time,
    table_name,
    MAX_FILE_DATE,
    rows_loaded,
    schema,
    db,
):
    """Load data into the control table in Snowflake and return status messages."""
    try:
        messages = TT.loadControlTable(
            db,
            schema,
            CURRENT_TIMESTAMP,
            Incremental_Start_Value,
            Incremental_End_Value,
            Extraction_Start_Time,
            Extraction_End_Time,
            table_name,
            MAX_FILE_DATE,
            rows_loaded,
        )

        if "FAIL_SIGNAL" in messages:
            return {"status": False, "message": messages}
        else:
            return {"status": True, "message": messages}
    except Exception as e:
        error_message = f"Error in load_control_table {table_name}: {e}"
        print(error_message)
        return {"status": False, "message": error_message}

# helper function to get model.json from snowflake table
def getModelJson():
    messages = []
    db = LZ_DB
    schema = LZ_SCHEMA
    conn, messages = TT.getSnowFlakeConn(db, schema, messages)
    table_name = MODEL_JSON_TABLE_NAME
    if conn != "no connection":
        try:
            cur = conn.cursor()
            query = f'SELECT JSONFIELD FROM {table_name} WHERE _FILEDATE = (SELECT MAX(_FILEDATE) FROM {table_name});'
            cur.execute(query)
            results = cur.fetchall()
            data = [i[0] for i in results]
            data = json.loads(data[-1])
            messages.append(
                f"readControlTable(): Read from snowflake completed for {db}, {schema}, CONTROLTABLE- {data}"
            )
            conn.close()
            return data, messages
        except Exception as e:
            print(f"Error reading from snowflake: ,{table_name}")
            print(e)
            messages.append(f"FAIL_SIGNAL")
            messages.append(
                f"Read Data: Read from snowflake failed for {db}, {schema}, {table_name}: {e}"
            )
            conn.close()
            return None, messages    
    
# helper function to check folder name
def checkRun(blob_name, run_pattern, previousRun, finalRun):
    pattern_check = re.match(run_pattern, blob_name)
    if pattern_check:
        run_name = blob_name.split('/')[-2]
        previous_check = ((previousRun and run_name > previousRun) or not previousRun)
        final_check = ((finalRun and run_name < finalRun) or not finalRun)
        return bool(previous_check and final_check)
    return False


# gathers all the variables needed for the thread executor
def processFolder(blob_name, entities, src_container, tgt_container, file_uploader_config, RUN_FILE):
    folder_errors = 0
    args = []
    log = []
    missing_entities = []
    run_name = blob_name.split('/')[-2]

    try:
        model_blob = src_container.download_blob(run_name+'/model.json')
    except:
        message = f'No model.json found in {run_name}'
        # tgt_container.upload_blob(f'{MANIFEST_PATH}{run_name}/{run_name}.txt', message, overwrite=True)
        # tgt_container.upload_blob(f'{MANIFEST_PATH}ERRORS/{run_name}/{run_name}.txt', message, overwrite=True)
        # folder_errors += 1
        warnings.warn(message)
        return [], message, folder_errors, missing_entities
    
    model_blob_content = model_blob.readall()
    model_json = json.loads(model_blob_content.decode('utf-8-sig'))
    entities_json = {e.get('name'): e for e in model_json.get('entities')}
    ignores = ['Microsoft.Athena.TrickleFeedService', 'OptionsetMetadata', 'email']

    for blob in src_container.walk_blobs(name_starts_with=run_name+'/'):
        try:
            entity_name = blob.name.split('/')[-2]
            arg_entities_check = bool(entities and entity_name.lower() in entities)
            ignored_entities_check = bool(not entities and entity_name not in ignores)
            if blob.name.endswith('/') and (arg_entities_check or ignored_entities_check):
                past_runs,msg = readRuntimeConfig(entity_name.lower()) 
                #past_runs = runs_json.get('RunData').get(entity_name.lower())
                past_runs_check = bool(past_runs is None or run_name not in past_runs)
                if past_runs_check:
                    entity_json = entities_json.get(entity_name)
                    if entity_name.upper() in file_uploader_config:
                        file_config_dict = file_uploader_config[entity_name.upper()]
                        args.append([entity_name, run_name, src_container, tgt_container, entity_json, file_config_dict])
                    else:
                        missing_entities.append(entity_name)
                        warnings.warn(f'Entity {entity_name.upper()} not found in File Uploader config')
                        
        except Exception as e:
            message = f'Failed to check {blob.name} with the following error: {e}'
            log.append(message)
            # tgt_container.upload_blob(f'{MANIFEST_PATH}{run_name}/{run_name}.txt', message, overwrite=True)
            # tgt_container.upload_blob(f'{MANIFEST_PATH}ERRORS/{run_name}/{run_name}.txt', message, overwrite=True)
            folder_errors += 1
    
    entity_range = f'({args[0][0]}, ..., {args[-1][0]})' if args else ''
    log.append(f'Gathered {len(args)} entity arguments {entity_range} from {run_name}')
    return args, '\n'.join(log), folder_errors, missing_entities


# upload each entities partitioned csvs to snowflake
def processEntity(vars):
    entity_name, run_name, src_container, tgt_container, entity_json, file_config_dict = vars
    entity_path = f'{run_name}/{entity_name}/'
    print(entity_name,run_name,file_config_dict)
    messages = [str(datetime.now())]
    failure_count = 0
    total_row_count = 0

    try:
        try: #uses runs model.json by default
            attributes = entity_json['attributes']
            header_formats = {a['name']: a['dataType'].lower() for a in attributes}
        except: #if model.json fails use TrickleFeedService
            try:
                message = f'Entity {entity_name} not found in {run_name}/model.json'
                messages.append(message)
                cdm_path = f'{run_name}/Microsoft.Athena.TrickleFeedService/{entity_name}/{entity_name}.cdm.json'
                cdm_blob = src_container.download_blob(cdm_path)
                cdm_json = json.loads(cdm_blob.readall().decode('utf-8-sig'))
                attributes = cdm_json['definitions'][0]['hasAttributes']
                header_formats = {column['name']: column['dataFormat'].lower() for column in attributes}
            except: # otherwise use most current json
                message = f'Entity {entity_name} not found in Microsoft.Athena.TrickleFeedService'
                messages.append(message)
                attributes = [e for e in master_model_json['entities'] if e['name'] == entity_name][0]['attributes']
                header_formats = {a['name']: a['dataType'].lower() for a in attributes}

        try: 
            partitions = entity_json.get('partitions')
            partition_file_formats = {p.get('name'): p.get('fileFormatSettings') if p.get('fileFormatSettings') else default_file_format for p in partitions}
        except Exception as e:
            message = 'Error reading partition formats: {e}'
            print(message)
            messages.append(message)
            partition_file_formats = {}

        for blob in src_container.walk_blobs(name_starts_with=entity_path):
            print(f'Processing partition file: {blob.name}')
            partition_file_name = blob.name.split('/')[-1]

            try: names = list(header_formats.keys())
            except: names = []

            try: file_format = partition_file_formats[partition_file_name.split('.')[0]]
            except: file_format = default_file_format

            try: sep = file_format['delimiter'] 
            except: sep = ','

            try: encoding = file_format['encoding'] 
            except: encoding = 'UTF-8'

            try: quoting = quote_styles[file_format['csvStyle']] 
            except: quoting = csv.QUOTE_ALL

            blob_url = src_container.url.replace('dataverse-globalcrmpro-org32011c87', 'dataverse-globalcrmpro-org32011c87/'+blob.name)

            chunk_count = 0
            
            for file_chunk in pd.read_csv(blob_url, names=names, sep=sep, chunksize=100_000, engine="python", encoding=encoding, quoting=quoting, dtype=str):
                chunk_count += 1
                row_count = len(file_chunk.index)
                total_row_count += row_count
            
                # process to json and post chunk to snowflake
                if row_count > 0:
                    db = LZ_DB
                    schema = file_config_dict['SNOWFLAKE_SCHEMA_NAME']
                    table_name = file_config_dict['SNOWFLAKE_TABLE_NAME']
                    new_file_name_txt = f'{run_name}-{entity_name}-{partition_file_name}-{chunk_count}.json'
                    
                    try:
                        filedate = datetime.strptime(run_name, '%Y-%m-%dT%H.%M.%SZ')
                        json_list = file_chunk.replace({np.nan:None}).to_dict('records')

                        message = TT.putSnowflakeDataFrame(db,schema,table_name,json_list,new_file_name_txt,filedate)
                        if 'FAIL_SIGNAL' in message:
                            message_str = '\n'.join(message)
                            print(message_str)
                            messages.append(message_str)
                            failure_count += 1
                        del message
                        
                        message = f'Processed {row_count} rows for {new_file_name_txt}'

                    except Exception as e:
                        message = f"Error writing to Snowflake: {db}.{schema}.{table_name}, {new_file_name_txt}: {e}"
                        failure_count += 1
                    
                    print(message)
                    messages.append(message)
            
        print(f'Processing metadata for entity {entity_name}')
        meta_failures = processMetadata(entity_name, run_name, src_container, messages)
        failure_count += meta_failures

    except Exception as e:
        failure_count += 1
        message = f"Error processing entity {run_name}/{entity_name}: {e}"
        messages.append(message)
        print(message)

    final_message = f'Succesfully processed entity {entity_path} and uploaded a total of {total_row_count} rows with a total of {failure_count} errors\n'
    messages.append(final_message)

    # messages_str = '\n'.join(messages)
    # tgt_container.upload_blob(f'{MANIFEST_PATH}{run_name}/{entity_name}.txt', messages_str, overwrite=True)
    # if failure_count > 0:
    #     tgt_container.upload_blob(f'{MANIFEST_PATH}ERRORS/{run_name}/{entity_name}.txt', messages_str, overwrite=True)
    
    return final_message, failure_count, entity_name, run_name ,total_row_count


# upload the metadata of a given entity
def processMetadata(entity_name, run_name, src_container, messages):
    meta_failures = 0
    try:

        metadata_path = f'{run_name}/Microsoft.Athena.TrickleFeedService/{entity_name}-EntityMetadata.json'

        downloader = src_container.download_blob(metadata_path, max_concurrency=16)
        blob_content = downloader.readall()
        blob_decompress = blob_content.decode('utf-8-sig')
        blob_json = json.loads(blob_decompress)

        metadata_entities = ['StateMetadata', 'StatusMetadata', 'GlobalOptionSetMetadata', 'OptionSetMetadata', 'TargetMetadata', 'AttributeMetadata']
        for meta_name in metadata_entities:

            meta_data = blob_json[meta_name]
            if meta_data:
                
                df = pd.DataFrame(meta_data, dtype='string')

                meta_config = metadata_config[meta_name.upper()]
                db = LZ_DB
                schema = meta_config['SNOWFLAKE_SCHEMA_NAME']
                table_name = meta_config['SNOWFLAKE_TABLE_NAME']
                new_file_name_txt = f'{run_name}-{entity_name}-{meta_name}.json'
                filedate = datetime.strptime(run_name, '%Y-%m-%dT%H.%M.%SZ')
                row_count = len(df)
                json_list = df.replace({np.nan:None}).to_dict('records')

                message = TT.putSnowflakeDataFrame(db,schema,table_name,json_list,new_file_name_txt,filedate)          
                if 'FAIL_SIGNAL' in message:
                    message_str = '\n'.join(message)
                    print(message_str)
                    messages.append(message_str)
                    meta_failures += 1
                del message
                
                message = f'Processed {row_count} meta rows for {entity_name}.{meta_name}'
                print(message)
                messages.append(message)
            
            else:
                message = f'No metadata in {entity_name}.{meta_name}'
                print(message)
                messages.append(message)
            
    except Exception as e:
        meta_failures += 1
        message = f"Error processing entity metadata {run_name}/{entity_name}: {e}"
        messages.append(message)
    
    print(f'Completed processing {entity_name} metadata with {meta_failures} errors') 
    return meta_failures


# main method
def main(srcAccount:str='PROD1', previousRun:str="", finalRun:str="", entities:list=[], entityThreaded:bool=True):
    global master_model_json, metadata_config

    print(f'previousRun: {previousRun}, finalRun: {finalRun}, entities: {entities}')
    FILEUPLOADER_CONFIG, THREADS, RUN_FILE = getTELToolsConfig()
    print(f'''TEL Tools values:
        tel_tools_config_path: {tel_tools_config_path}
        FILEUPLOADER_CONFIG: {FILEUPLOADER_CONFIG}
        THREADS: {THREADS}
        RUN_FILE: {RUN_FILE}
    ''')

    file_uploader_config = TT.getFileUploaderConfig(FILEUPLOADER_CONFIG)
    metadata_config = {k:v for k, v in file_uploader_config.items() if k.upper().endswith('METADATA')}
    
    result,message = readRuntimeConfig('LastDefaultRun')
    if not result:
        raise Exception(f'Unable to load LastDefaultRun')

    LastDefaultRun = result[0]
    print(message,LastDefaultRun)
    print(f'Run started for LastDefaultRun: {LastDefaultRun}')

    default_flag = not (previousRun or finalRun or entities)
    
    sas_key_src = 'AZURE-STORAGE-CRM-SAS-PRODDWH'
    sas_url_src = TT.getAzureSecret(sas_key_src).value
    if sas_url_src:
        src_container = ContainerClient.from_container_url(sas_url_src, 
                                                        max_single_get_size=1024*1024, 
                                                        max_chunk_get_size=1024*1024)
    else:
        raise Exception(f'Unable locate MS Dynamics Azure Key Vault secret from {sas_key_src}')

    if not previousRun:
        previousRun = LastDefaultRun if LastDefaultRun else '0000'

    if not finalRun:
        try:
            changelog_path = 'Changelog/changelog.info'
            changelog_blob = src_container.download_blob(changelog_path)
            finalRun = changelog_blob.readall().decode('utf-8-sig')
        except:
            last_dt = datetime.now() - timedelta(minutes=15)
            finalRun = last_dt.strftime('%Y-%m-%dT%H.%M.%SZ')

    print(f'Adjusted date range:  previousRun: {previousRun}, finalRun: {finalRun}')

    tgt_container = '' #Blank Target Container : Just incase You want to re-enable Blob Storage Running.

    # sas_key_tgt = 'AZURE-STORAGE-CRM-SAS-SFSA'
    # sas_url_tgt = TT.getAzureSecret(sas_key_tgt).value
    # if sas_url_tgt:
    #     tgt_container = ContainerClient.from_container_url(sas_url_tgt)
    # else:
    #     raise Exception(f'Unable locate SFSA Azure Key Vault secret from {sas_key_tgt}')
    # print(f'Connected to {src_container.container_name}')

    try:
        model_blob = src_container.download_blob('model.json')
        model_content = model_blob.readall()
        master_model_json = json.loads(model_content.decode('utf-8-sig'))
        # Adding a snowflake Table Called MODEL_JSON to completely Remove Blob Storage Dependency
        print('Downloaded model.json from data lake')
        message = TT.putSnowflakeDataFrame(db=LZ_DB, schema=LZ_SCHEMA,tableName=MODEL_JSON_TABLE_NAME, fileDate=datetime.strptime(finalRun,"%Y-%m-%dT%H.%M.%SZ"),df =[master_model_json],fileName=f'model_json_{finalRun.replace(" ","")}',row_count=len(master_model_json))
        if 'FAIL_SIGNAL' in message:
            print('Failed To Upload model.json in snowflake')
        else:
            print('Sucessfully Uploaded model.json in snowflake') 
        
        # create summarized schema.csv
        try:
            tables, columns, dtypes = ([], [], [])
            for entity in master_model_json['entities']:
                new_columns = [a['name'] for a in entity['attributes']]
                tables.extend([entity['name']]*len(new_columns))
                columns.extend(new_columns)
                dtypes.extend([a['dataType'] for a in entity['attributes']])
                
            df = pd.DataFrame({'Table': tables, 'Column': columns, 'CRM Type': dtypes})
            df['SF Type'] = df['CRM Type'].str.lower().map(dtype_conversions)
            # df_string = df.to_csv(index=False)
            # tgt_container.upload_blob('schema.csv', df_string, overwrite=True)
            
            # Upload schema.csv to a table called SCHEMA_TABLE
            df.columns = ["table_name","column_name","data_type_in_crm","data_type_in_snowflake"]
            message = TT.putSnowflakeDataFrame(db=LZ_DB, schema=LZ_SCHEMA,tableName=SCHEMA_CSV_TABLE_NAME,fileDate=datetime.strptime(finalRun,"%Y-%m-%dT%H.%M.%SZ"),df = df,fileName=f'schema_table_{finalRun.replace(" ","")}',row_count=len(df))
            if 'FAIL_SIGNAL' in message:
                print('Failed To Upload model.json in Snowflake')
            else:
                print('Succesfully updated schema.csv')
        except:
            print('Failed to update schema.csv')

    except Exception as e :
        print(e)
        # model_blob = tgt_container.download_blob('model.json')
        # model_content = model_blob.readall()
        # master_model_json = json.loads(model_content.decode('utf-8-sig'))
        # print('Downloaded model.json from SFSA')

        master_model_json, message = getModelJson()
        print('Downloaded model.json from Snowflake')

    
    print('Filtering run folders...')
    run_pattern = f'\\d{{4}}-\\d{{2}}-\\d{{2}}T\\d{{2}}.\\d{{2}}.\\d{{2}}Z/'
    run_names = [blob.name for blob in src_container.walk_blobs() if checkRun(blob.name, run_pattern, previousRun, finalRun)]

    if run_names:
        print(f'Matched {len(run_names)} folders between {run_names[0]} and {run_names[-1]}')

        run_args = []
        total_errors = 0
        control_table_errors = 0
        all_missing_entities = []
        with ThreadPoolExecutor(max_workers=THREADS) as exe:
            print(f'Getting entity arguments. Threading max workers: {exe._max_workers}.')
            for result in exe.map(processFolder, run_names, repeat(entities), repeat(src_container), repeat(tgt_container), repeat(file_uploader_config), repeat(RUN_FILE)):
                arg, log, errors, missing_entities = result
                all_missing_entities.extend(missing_entities)
                print(log)
                total_errors += errors
                if arg:
                    run_args.append(arg)

        if run_args:
            total_entities = sum(len(arg) for arg in run_args)
            print(f'Found {total_entities} entities across {len(run_args)} folders')

            entity_args = [entity_arg for run_arg in run_args for entity_arg in run_arg]
            with ThreadPoolExecutor(max_workers=THREADS) as exe:
                print(f'Processing entities. Threading max workers: {exe._max_workers}.')
                for result in exe.map(processEntity, entity_args):
                    msg, error_count, entity_name, run_name,total_row_count = result
                    print(msg)
                    if error_count == 0:
                        batch_end_datetimestamp = datetime.now()
                        control_table_result = load_control_table(
                            CURRENT_TIMESTAMP,
                            LastDefaultRun,
                            run_name,
                            str(batch_datetimestamp),
                            str(batch_end_datetimestamp),
                            entity_name,
                            'NA',
                            total_row_count,
                            LZ_SCHEMA,
                            LZ_DB
                            )
                        print(control_table_result)
                        if control_table_result['status'] == False:
                            control_table_errors += 1
                            print(control_table_result['message'])

                    total_errors += error_count
                    total_errors += control_table_errors
            print(f'Finished processing entities\n')                
            print(f'Finished processing all files with a total of {total_errors} errors.')
            
            if total_errors > 0:
                raise Exception(f'{total_errors} ERRORS')
            elif all_missing_entities:
                warnings.warn(f'File Uploader missing configs: {all_missing_entities}')
            elif default_flag and run_args:
                LastDefaultRun = run_args[-1][0][1]
                control_table_params = {'CURRENT_TIMESTAMP':CURRENT_TIMESTAMP,
                                        'Incremental_Start_Value':'',
                                        'Incremental_End_Value':LastDefaultRun,
                                        'Extraction_Start_Time':'',
                                        'Extraction_End_Time':'',
                                        'table_name':'LastDefaultRun',
                                        'MAX_FILE_DATE':'',
                                        'rows_loaded':'',
                                        'schema':LZ_SCHEMA,
                                        'db':LZ_DB,}
                control_table_result = load_control_table(**control_table_params)
                if control_table_result['status'] == False:
                    raise Exception(f"Failure in updating LastDefaultRun {control_table_result['message']}")
                else:
                    print(f'Updated LastDefaultRun to {LastDefaultRun}')                           
        else:
            print('No entities found')
    else:
        print('No matched folders')

if __name__ == '__main__':

    args = dict(arg.split('=') for arg in sys.argv[1:])

    srcAccount = args.get('srcAccount')
    srcAccount = srcAccount.upper() if srcAccount else 'PROD1'

    previousRun = args.get('previousRun')
    previousRun = previousRun.upper() if previousRun else ''

    finalRun = args.get('finalRun')
    finalRun = finalRun.upper() if finalRun else ''

    entities = args.get('entities')
    entities = entities.lower().split(',') if entities else []
    
    entityThreaded = args.get('entityThreaded')
    entityThreaded = entityThreaded.upper()!='FALSE' if entityThreaded else True

    main(srcAccount=srcAccount, previousRun=previousRun, finalRun=finalRun, entities=entities, entityThreaded=entityThreaded)
