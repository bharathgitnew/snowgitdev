
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

# globals
batch_datetimestamp = datetime.now()
CURRENT_TIMESTAMP = str(datetime.now()).replace(" ","_").replace(":","_").replace(".","_")
tel_tools_config_path = '/usr/local/airflow/include/Configuration/TelTools_ITHD.json'
ENV = os.environ['SNOWFLAKE_ENV']
LZ_DB = os.environ["SNOWFLAKE_LZ"]
LZ_SCHEMA = 'ITHD'
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


# functions

# load config entries from TELTools.json
def getTELToolsConfig():
    with open(tel_tools_config_path,'r') as f:
        ithd_json = json.load(f,strict=False)
        machines = ithd_json.get('Machines').get(ENV)
        THREADS = int(machines.get('THREADS'))
        RUN_FILE = machines.get('RUN_FILE')
        file_uploader_config = ithd_json.get('DataSets')
    return THREADS, RUN_FILE, file_uploader_config


# get incremental value
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
        folder_errors += 1
        warnings.warn(message)
        return [], message, folder_errors, missing_entities
    model_blob_content = model_blob.readall()
    model_json = json.loads(model_blob_content.decode('utf-8-sig'))
    entities_json = {e.get('name'): e for e in model_json.get('entities')}
    ignores = ['Microsoft.Athena.TrickleFeedService', 'OptionsetMetadata']

    for blob in src_container.walk_blobs(name_starts_with=run_name+'/'):
        try:
            entity_name = blob.name.split('/')[-2]
            arg_entities_check = bool(entities and entity_name.lower() in entities)
            ignored_entities_check = bool(not entities and entity_name not in ignores)
            if blob.name.endswith('/') and (arg_entities_check or ignored_entities_check):                
                past_runs,msg = readRuntimeConfig(entity_name.lower())                
                past_runs_check = bool(past_runs is None or run_name not in past_runs)
                if past_runs_check:
                    entity_json = entities_json.get(entity_name)
                    if entity_name.upper() not in file_uploader_config:
                        missing_entities.append(entity_name)
                        raise Exception(f'Entity {entity_name.upper()} not found in File Uploader config')
                    file_config_dict = file_uploader_config[entity_name.upper()]
                    args.append([entity_name, run_name, src_container, tgt_container, entity_json, file_config_dict])
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

            blob_url = src_container.url.replace('dataverse-itsupportcen-telist', 'dataverse-itsupportcen-telist/'+blob.name)

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

                        message = TT.putSnowflakeDataFrame(db,schema,table_name,json_list,new_file_name_txt,filedate,row_count)
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

    final_message = f'Entity processed of {entity_path} and uploaded a total of {total_row_count} rows with a total of {failure_count} errors\n'
    messages.append(final_message)

    messages_str = '\n'.join(messages)

    # tgt_container.upload_blob(f'{MANIFEST_PATH}{run_name}/{entity_name}.txt', messages_str, overwrite=True)
    # error_path  = f'{MANIFEST_PATH}ERRORS/{run_name}/{entity_name}.txt'
    # if failure_count == 0:
    #     if bool(list(tgt_container.list_blobs(error_path))):
    #         tgt_container.delete_blob(error_path)
    # else:
    #     tgt_container.upload_blob(error_path, messages_str, overwrite=True)
    
    return final_message, failure_count, entity_name, run_name,total_row_count


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

                message = TT.putSnowflakeDataFrame(db,schema,table_name,json_list,new_file_name_txt,filedate,row_count)          
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
    
    print(f'Metadata processed of {entity_name} with {meta_failures} errors') 
    return meta_failures


# main method
def main(previousRun:str="", finalRun:str="", entities:list=[]):
    global master_model_json, metadata_config

    print(f'previousRun: {previousRun}, finalRun: {finalRun}')
    print(f'{len(entities)} entities: {entities}')

    THREADS, RUN_FILE, file_uploader_config = getTELToolsConfig()
    print(f'''TEL Tools variables:
        tel_tools_config_path: {tel_tools_config_path}
        THREADS: {THREADS}
        RUN_FILE: {RUN_FILE}
    ''')

    metadata_config = {k:v for k, v in file_uploader_config.items() if k.upper().endswith('METADATA')}
    num_configured_entities = len(file_uploader_config)-len(metadata_config)

    result,message = readRuntimeConfig('LastDefaultRun')
    if not result:
        raise Exception(f'Unable to load LastDefaultRun')

    LastDefaultRun = result[0]
    print(f'Sucessfully Fetched LastDefaultRun:{LastDefaultRun}\n{message}')

    default_flag = not (previousRun or finalRun or (entities and len(entities)!=num_configured_entities))
    print(f'{default_flag = }')

    sas_key_src = 'AZURE-STORAGE-ITHD-SAS'
    sas_url_src = TT.getAzureSecret(sas_key_src).value
    if sas_url_src:
        src_container = ContainerClient.from_container_url(sas_url_src)
    else:
        raise Exception(f'Unable locate MS Dynamics Azure Key Vault secret from {sas_key_src}')

    if not previousRun:
        previousRun = LastDefaultRun or '0000'

    try:
        changelog_path = 'Changelog/changelog.info'
        changelog_blob = src_container.download_blob(changelog_path)
        newest_run = changelog_blob.readall().decode('utf-8-sig')
    except:
        last_dt = datetime.now() - timedelta(minutes=15)
        newest_run = last_dt.strftime('%Y-%m-%dT%H.%M.%SZ')
    if not finalRun or finalRun > newest_run:
        finalRun = newest_run

    print(f'Adjusted date range:  previousRun: {previousRun}, finalRun: {finalRun}')

    tgt_container = ''
    # sas_key_tgt = 'AZURE-STORAGE-ITHD-SAS-SFSA'
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
        print('Downloaded model.json from data lake')
        # tgt_container.upload_blob('model.json', model_content, overwrite=True)
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
                
            df = pd.DataFrame({'Table': tables, 'Column': columns, 'ITHD Type': dtypes})
            df['SF Type'] = df['ITHD Type'].str.lower().map(dtype_conversions)
            df_string = df.to_csv(index=False)
            # tgt_container.upload_blob('schema.csv', df_string, overwrite=True)
            # print('Succesfully updated schema.csv')
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
    newest_complete_run = ''
    run_names = []
    for blob in src_container.walk_blobs():
        blob_name = blob.name
        pattern = '\\d{4}-\\d{2}-\\d{2}T\\d{2}.\\d{2}.\\d{2}Z'
        if re.match(pattern, blob_name):
            if blob_name > newest_complete_run and blob_name < newest_run:
                newest_complete_run = blob_name
            if blob_name > previousRun+'/' and blob_name < finalRun:
                run_names.append(blob_name)
    results = {}

    if run_names:
        print(f'Matched {len(run_names)} folders between {run_names[0]} and {run_names[-1]}')

        run_args = []
        total_errors = 0
        control_table_errors = 0

        with ThreadPoolExecutor(max_workers=THREADS) as exe:
            print(f'Getting entity arguments. Threading max workers: {exe._max_workers}.')
            for result in exe.map(processFolder, run_names, repeat(entities), repeat(src_container), repeat(tgt_container), repeat(file_uploader_config), repeat(RUN_FILE)):
                arg, log, errors, missing_entities = result
                print(log)
                total_errors += errors
                if missing_entities:
                    warnings.warn(f'File Uploader missing configs: {missing_entities}')
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
                    total_errors += error_count
                    print(msg)

                    if error_count == 0:
                        status = 'SUCCESS'
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
                        if control_table_result['status'] == False:
                            control_table_errors += 1
                            print(control_table_result['message'])
                    else:
                        status = 'FAILED'
                    
                    total_errors += control_table_errors
                    
                    if run_name in results:
                        results[run_name] |= {entity_name.upper(): {'status': status, 'message': msg}}
                    else:
                        results[run_name] = {entity_name.upper(): {'status': status, 'message': msg}}
                    
            if total_errors == 0:
                if default_flag and run_args:
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

                print(f'Finished processing {len(results)} folders with a total of {total_errors} errors.')
            else:
                print(f'Finished processing {len(results)} folders with a total of {total_errors} errors.')
                raise Exception(f'{total_errors} ERRORS')
            
        else:
            print('No entities found')
    else:
        print('No matched folders')
    
    return results


if __name__ == '__main__':

    args = dict(arg.split('=') for arg in sys.argv[1:])

    previousRun = args.get('previousRun')
    previousRun = previousRun.upper() if previousRun else ''

    finalRun = args.get('finalRun')
    finalRun = finalRun.upper() if finalRun else ''

    entities = args.get('entities')
    entities = entities.lower().split(',') if entities else []
    
    main(previousRun=previousRun, finalRun=finalRun, entities=entities)
