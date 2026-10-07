import requests
from urllib import parse
import json 
import os
import sys
import datetime
import logging
import pandas as pd
import include.Python.TELTools as TT
from azure.storage.blob import ContainerClient, __version__
from concurrent.futures import ThreadPoolExecutor
import time

import warnings
warnings.filterwarnings("ignore")
# versioning
# Pre-go live refator ec4/13/2023, added config file entries in teltools
# example file call to load from API: python .\getSAPAPIFILE.py "ALL" "NOLIMIT" "FALSE"
# example file call to load from replay queue: python .\getSAPAPIFILE.py "ALL" "NOLIMIT" "TRUE"n

# Globals
api_call_datetimestamp = datetime.datetime.now()
api_call_datetimestamp_utc = datetime.datetime.now(datetime.timezone.utc)
CURRENT_TIMESTAMP = str(api_call_datetimestamp).replace(" ","_").replace(":","_").replace(".","_")
Incremental_Start_Value=CURRENT_TIMESTAMP
Extraction_Start_Time=CURRENT_TIMESTAMP
Extraction_End_Time=CURRENT_TIMESTAMP
MAX_FILE_DATE=CURRENT_TIMESTAMP
# end_time=CURRENT_TIMESTAMP
cds_view=''
failed_files = 'None'
FORMAT = 'json'
# tel_tools_path = '/usr/local/airflow/include/Configuration/TelTools_SAPAPI_Connectors.json'
#tel_tools_path = 'F:\\Shares\\Configuration\\TelTools_SAPAPI_Connectors.json'
RUNTIME_ENV = os.environ.get("RUNTIME_ENV", "windows").lower()
print(f"Runtime environment: {RUNTIME_ENV}")
script_dir = os.path.dirname(__file__)

_config_file = (
    "TelTools_SAPAPI_Connectors_mini.json"
    if RUNTIME_ENV != "astro"
    else "TelTools_SAPAPI_Connectors.json"
)

tel_tools_path = os.path.abspath(
    os.path.join(script_dir, "..", "Configuration", _config_file)
)



ENV = os.environ['SNOWFLAKE_ENV']
LZ_DB = os.environ["SNOWFLAKE_LZ"]

# load config entries from TELTools.json
def getTELToolsConfig():
    # load from teltools.json

    with open(tel_tools_path,'r') as f:
        tel_tools_json = json.load(f,strict=False)
        sapapi_json = tel_tools_json.get('SAPAPI').get(ENV)
        APP_ID = sapapi_json.get('APP_ID')
        SAP_USER = sapapi_json.get('USER_NAME')
        api_url_part1 = sapapi_json.get('URL')
        api_url_part2 = sapapi_json.get('METHOD')
        file_out_location = sapapi_json.get('FILE_OUT')
        SAP_API_KEY = sapapi_json.get('SAP_API_KEY')
        THREADS = int(sapapi_json.get('THREADS'))
        CLIENT = sapapi_json.get('CLIENT')
        config_path = sapapi_json.get('CONFIG_FILE_PATH')
        incremental_path = sapapi_json.get('INCREMENTAL_FILE_PATH')    
    
    return APP_ID,SAP_USER,api_url_part1,api_url_part2,config_path,incremental_path,file_out_location,SAP_API_KEY,THREADS,CLIENT

#read sapai config file
def read_config_file(file_path):
    try:
        if os.path.exists(file_path):
            with open(file_path, 'r') as json_file:
                json_data = json.load(json_file)
            return json_data
        else:
            print(f"Error: File not found at path {file_path}")
            return None
    except Exception as e:
        print(f"Error occurred at read_config_file : {e}")
        return None

# post API data to LZ snowflake
def post_to_snowflake(sf_db,sf_schema,sf_table,json_list,file_name,row_count):
    #file_config = file_uploader_json.get(cds_view)
    db = sf_db
    schema = sf_schema
    tableName = sf_table
    messages = [f'post_to_snowflake() method failed for {file_name}']

    try:
        messages = TT.putSnowflakeDataFrame(db,schema,tableName,json_list,file_name,api_call_datetimestamp,row_count)
        print(f'TT.putSnowflakeDataFrame(): {messages}')
        if "FAIL_SIGNAL" in messages:
            return 1,messages
        else:
            return 0,messages
    except Exception as e:
        print (f"Error writing to snowflake: ,{file_name}")
        print(e)
        return 1,messages

def load_control_table(cds_view,CURRENT_TIMESTAMP,Incremental_Start_Value,Incremental_End_Value,Extraction_Start_Time,Extraction_End_Time,cds,MAX_FILE_DATE,rows_loaded):
    db = LZ_DB
    schema = 'SAPAPI'
    # tableName = file_config.get('SNOWFLAKE_TABLE_NAME')
    messages = [f'load_control_table() method failed for {cds}']
    try:
        messages = TT.loadControlTable(db,schema,CURRENT_TIMESTAMP,Incremental_Start_Value,Incremental_End_Value,Extraction_Start_Time,Extraction_End_Time,cds,MAX_FILE_DATE,rows_loaded)
        print(f'TT.loadControlTable(): {messages}')
        if "FAIL_SIGNAL" in messages:
            return 1,messages
        else:
            return 0,messages
    except Exception as e:
        print (f"TT.loadControlTable() : Error writing to snowflake: ,{cds}")
        print(e)
        return 1,messages

# upload dataframe to blob
# def uploadblob(tgt_container,json_list,file_name):
    
#     try:
#         output = io.StringIO()
#         output = json.dumps(json_list)
#         ContainerClient.upload_blob(tgt_container, file_name, output, overwrite=True, encoding='utf-8')
#         message = f'upload_blob(): Successfully archived: {file_name}'
#         print(message)
#     except Exception as e:
#         message = f"Upload_blob method failed for {file_name}: {e}"
#         print(message)
#         return 1,message
#     return 0,message

#check for input selection ALL/SINGLE/MULTI (ALL-whole config,SINGLE-only one cds,MULTI-multiple cds [cds1,cds1,cds3,...]) 
def inputSelection(config,section):
    section_s = [sec.strip() for sec in section.split(",")]
    if section == 'ALL':
        return config,section
    if len(section_s) == 1:
        return config,section
    if len(section_s) > 1:
        section = 'MULTI'
        sliced_config = {}
        for cds in config:
            if cds in section_s:
                sliced_config[cds] = config[cds]
        return sliced_config,section

def day_minus_one(date_str):
    date_obj = datetime.datetime.strptime(date_str, "%Y%m%d")
    # Subtract one day
    previous_date_obj = date_obj - datetime.timedelta(days=1)
    previous_date_str = previous_date_obj.strftime("%Y%m%d")
    return previous_date_str

# load CDS runtime config file 
def read_runtime_config():
    msg = []
    db = LZ_DB
    schema = 'SAPAPI'
    table = None
    runtimeConfig , msg = TT.readControlTable(db,schema,table)
    print(f'read_runtime_config(): {runtimeConfig} {msg}')
    return runtimeConfig, msg

# build CDS URL, retreive and process the data and output to csv
def get_CDS_data(API_KEY,file_out_location,api_url_part1,api_url_part2,client,payload,section,cds_view,CDS_view_history,row_limit,strategy,incremental_field,tgt_container,archive_file,sf_db,sf_schema,sf_table):
    Incremental_Start_Value=CURRENT_TIMESTAMP
    Incremental_End_Value=CURRENT_TIMESTAMP
    Extraction_Start_Time=CURRENT_TIMESTAMP
    Extraction_End_Time=CURRENT_TIMESTAMP
    MAX_FILE_DATE=CURRENT_TIMESTAMP
    local_Time=CURRENT_TIMESTAMP
    #if using a strategy add a filter to the payload using the field passed
    filter = payload.get('$filter')
    if strategy == 'incremental':
        Extraction_Start_Time=str(datetime.datetime.now()).replace(" ","_").replace(":","_").replace(".","_")
        Extraction_End_Time=str(datetime.datetime.now()).replace(" ","_").replace(":","_").replace(".","_")
        history = CDS_view_history.get(section, None)  
        if history != None and history!= '':
            history_minusone = day_minus_one(history)
            Incremental_Start_Value=history
            filter = incremental_field+" ge '"+history+"' "+ filter
            # filter = "("+incremental_field+" eq null or "+incremental_field+" ge '"+history+"') "+ filter
            payload.update({'$filter':filter})
            print(section,'last successful run',history,'retrieving new data with filter: ',filter)
        else:
            Incremental_Start_Value='19000101'
            print('Incremental strategy, but no previous run of CDS view, will attempt to retrieve all data')
    elif strategy == 'prior-period':
        Incremental_Start_Value='19000101'
        prior_period_end = datetime.date.today().replace(day=1) - datetime.timedelta(days=1)
        prior_period_start = prior_period_end.replace(day=1).strftime("%Y%m%d")
        prior_period_end = prior_period_end.strftime("%Y%m%d")
        filter = incremental_field+" ge '"+str(prior_period_start)+"' and "\
                        +incremental_field+" le '"+str(prior_period_end)+"' and "\
                        "Rldnr eq '0L'"
        payload.update({'$filter':filter})
        print(section,'prior-period run for filter:',filter)
    elif strategy == 'incremental-param':
        # Parameter-based incremental (for CDS views with input parameters)
        Extraction_Start_Time = str(datetime.datetime.now()).replace(" ", "_").replace(":", "_").replace(".", "_")
        Extraction_End_Time = str(datetime.datetime.now()).replace(" ", "_").replace(":", "_").replace(".", "_")
        history = CDS_view_history.get(section, None)
        if history is not None and history != '':
            Incremental_Start_Value = history
            from_date = datetime.datetime.strptime(history, "%Y-%m-%dT%H:%M:%SZ")
            #safer_history = from_date - datetime.timedelta(minutes = 30)
            date_for_param = from_date.strftime("%Y-%m-%dT%H:%M:%SZ")
            
            print(section, 'last successful run', history, 'retrieving new data with param:', date_for_param)
        else:
            Incremental_Start_Value='1900-01-01T00:00:00Z'
            date_for_param = Incremental_Start_Value
            print('Incremental-param strategy, but no previous run, will attempt to retrieve all data')
    else:
        print('Full load strategy, will attempt to retrieve all data')

    # build url with cds view
    cds_ref = cds_view +'_CDS/'
    if strategy == 'incremental-param':
        param_string = f"(p_fromdatetime=datetimeoffset'{date_for_param}')/Set"
        URL = api_url_part1 + client + api_url_part2 + cds_ref + cds_view + param_string
    else:
        URL = api_url_part1 + client + api_url_part2 + cds_ref + cds_view
    # working variables
    init_row_limit = row_limit
    max_incremental_value = 0
    skip_records = 0
    file_count = 0
    failCount = 0
    failMax = 3
    success = False
    rows_loaded = 0
    snowflake_write_failures = 0
    json_parse_errors = 0
    blob_upload_errors = 0
    messages = []
    files_processed = ''

    # call data in batches
    while True:
        # set the dynamic batch size     
        logging.debug("Calling API...")
        payload.update({'$skip':skip_records,'$top':row_limit })
       
        # requests encodes $, need to prevent that
        payload_str = parse.urlencode(payload,safe=':$', encoding='utf-8',quote_via=parse.quote)    
        logging.debug("payload_str %s", payload_str)
        # call API
        df,row_count,total_row_count,status_code,response_text = call_api(API_KEY,payload_str,URL)
        
        # process API results
        if status_code == 0 and row_count > 0:
            # write to file after each read
            skip_records += row_limit
            file_count += 1
            file_name = section  + '.{}-{}.json'.format(CURRENT_TIMESTAMP,file_count)
            file_location = file_out_location + file_name
            logging.debug("writing to file %s", file_location)

            # process df response to json
            try:
                # json_list= df.apply(lambda x: json.loads(x.to_json()), axis=1).to_list()
                #json_list= df.replace({np.nan:None}).to_dict('records')
                json_list = json.loads(df.to_json(orient='records'))
            except Exception as e:
                json_parse_errors += 1
                message = f"Error parsing json: ,{cds_view}"
                messages.append(message)
                print (message)
                print(e)

            # upload json to snowflake with retry logic
            snowflake_post_attempts = 0
            snowflake_post_max_attempts = 3
            while snowflake_post_attempts < snowflake_post_max_attempts:
                failure,return_messages = post_to_snowflake(sf_db,sf_schema,sf_table,json_list,file_name,row_count)             
                messages.append(return_messages)
                if failure == 0:
                    break
                else:
                    snowflake_post_attempts += 1
                    if snowflake_post_attempts < snowflake_post_max_attempts:
                        print(f"Retrying post_to_snowflake for {file_name}, attempt {snowflake_post_attempts+1}...")
                        time.sleep(60 * snowflake_post_attempts)
                    else:
                        message = f"post_to_snowflake failed after {snowflake_post_max_attempts} attempts for {file_name}."
                        messages.append(message)
                        snowflake_write_failures += failure
                        print(message)
                        if ENV.upper() == 'PROD':
                            TT.sendEmail(
                                'BI.Production-Alert-no-reply@us.tel.com',
                                subject =f'SNOWFLAKE LOAD FAILURE NOTIFICATION: {CURRENT_TIMESTAMP}',
                                email_content=f'''
                                <br><b>{cds_view}</b> : The Snowflake Load Has Failed <br>
                                <br><b>File</b> : {file_name} <br>
                                <br><b>Message</b> : {message} <br>
                                <br><b>Return Messages</b> : {return_messages} <br>
                                '''
                            )
                        success = False
                        break
            if failure != 0:
                break

            logging.debug("Api Call Count %s Records Processed %s",file_count, row_limit)
            failCount = 0
            rows_loaded += row_count

            #archive the file to blob storage
            # if archive_file == "true":
            #     archive_filePath = f"ARCHIVE/{CURRENT_TIMESTAMP}/{file_name}"
            #     blob_upload_errors,blob_message = uploadblob(tgt_container,json_list,archive_filePath) 
            #     messages.append(blob_message)

            # capture max incremental value from batch
            if strategy.lower() == 'incremental' and row_limit != 1000:
                incremental_value = int(df[incremental_field].max() or 0)
                if incremental_value > max_incremental_value:
                    max_incremental_value = incremental_value

            # Log to manifest 
            files_processed = files_processed + file_name + "," + str(row_count) + "\n"

            # exit if last round or record limit applied
            op_failures = snowflake_write_failures +  json_parse_errors + blob_upload_errors
            if row_count < row_limit or row_limit == 1000:
                if op_failures == 0:
                    success = True
                break

            # increment up row count if it was previously stepped down
            if row_limit < init_row_limit: 
                row_limit += 5000
                print("Incrementing row_limit backup: ",row_limit,", original row_limit: ",init_row_limit)

        # no rows returned from successful api call
        elif status_code == 0 and row_count == 0:
            failCount +=1
            if failCount < failMax:
                message = f"No rows returned in api call {file_count} for {cds_view}, retrying."
                messages.append(message)
                print(message)
                continue
            else:
                message = f"API call aborted for {cds_view} due to no rows returned after max tries."
                messages.append(message)
                print(message)
                success = True
                break 

        #api call failed due to server disconnection, reduce pagination step and try again
        elif status_code == 1:
            failCount += 1
            sleep_time = 120 * failCount
            if row_limit > 5000:
                row_limit = int(row_limit/2)
            if failCount < failMax: 
                print("API call failed ",failCount," times for ",cds_view, " due to server reset, trying again with ",row_limit," record limit")
                time.sleep(sleep_time)
                continue
            else:
                message = "API call failed for ",cds_view," due to server reset."
                messages.append(message)
                print(message)
                if ENV == 'PROD':
                    TT.sendEmail(
                        'BI.Production-Alert-no-reply@us.tel.com',
                        subject =f'CDS VIEW FAILURE NOTIFICATION: {CURRENT_TIMESTAMP}',
                        email_content=f'''
                        <br><b>{cds_view}</b> : The Extraction Has Failed <br>
                        <br><b>Message</b> : {message} <br>
                        <br><b>API Response</b> : {response_text} <br>
                        '''
                    )
                break
        #api call failed for unknown reason
        else:
            message = f'API call failed for unknown reason, {cds_view}'
            messages.append(message)              
            print(message)
            if ENV.upper() == 'PROD':
                TT.sendEmail(
                        'BI.Production-Alert-no-reply@us.tel.com',
                        subject =f'CDS VIEW FAILURE NOTIFICATION: {CURRENT_TIMESTAMP}',
                        email_content=f'''
                        <br><b>{cds_view}</b> : The Extraction Has Failed <br>
                        <br><b>Message</b> : {message} <br>
                        <br><b>API Response</b> : {response_text} <br>
                        '''
                    )
            break
    
    # report success or failure
    if success: 
        message = "Completed: ",cds_view, \
            ", records queried: ",total_row_count,\
            ", records loaded: ",rows_loaded,\
            ", new incremental value: ",max_incremental_value
        print(message)
        messages.append(message)

        # if archive_file == "true":
        #     message = f'Blob files for {cds_view} were uploaded to archive successfully.'
        #     messages.append(message)
        # else: 
        #     message = f'Blob files for {cds_view} were not upload to archive, archive_file argument not set to <true>.'
        #     messages.append(message)
        
    else: 
        message = f'Attempted to load to SF {cds_view}, however an earlier part of the process failed, details in above message(s).'
        messages.append(message)
    
    Incremental_End_Value=max_incremental_value 
    if strategy == 'incremental-param':
        Incremental_End_Value = api_call_datetimestamp_utc - datetime.timedelta(minutes = 120)
        Incremental_End_Value = Incremental_End_Value.strftime("%Y-%m-%dT%H:%M:%SZ")
        
    Extraction_End_Time=str(datetime.datetime.now()).replace(" ","_").replace(":","_").replace(".","_")
    print("Get CDS Completed, Moving to Next Step")
    
    return messages,success,files_processed,max_incremental_value,local_Time, \
        Incremental_Start_Value,Incremental_End_Value, \
        Extraction_Start_Time,Extraction_End_Time,CDS_view_history,MAX_FILE_DATE,rows_loaded

# call the api with the correct payload/parameters
def call_api(API_KEY,payload, URL):
    try:
        df = pd.DataFrame() 
        row_count = 0
        total_row_count = 0
        response = requests.get(URL, params=payload,timeout=300, stream=True)
        status_code = response.status_code
        safe_url = response.url.replace(API_KEY,'apiKey')
        #print(safe_url)
        logging.debug(safe_url)
        print("url response time: ",response.elapsed, ", status_code: ",status_code)
        if status_code == 200:
            logging.debug("{}: Successful API call".format(status_code))
            results = response.json()
            total_row_count = int(results['d']['__count'])      
            df = pd.DataFrame(results['d']['results']) 
            row_count = len(df)
            if row_count > 0: df.drop(["__metadata"],axis=1,inplace=True) # 31545-hotfix for zero record views
            return df,row_count,total_row_count,0,None
        else:
            logging.error("API Error status code: {}".format(status_code))
            logging.debug("API url {}".format(response.url))
            logging.debug("API url {}".format(response.url))
            logging.debug("API Error status code: {}".format(status_code))
            df = pd.DataFrame() # return empty data frame
            return df,row_count,total_row_count,1,response.text
       
    except requests.exceptions.ChunkedEncodingError:
        logging.debug('Server did not respond in a timely manor')
        return df,0,0,1,None
    except requests.exceptions.ReadTimeout:
        logging.debug('Server timeout')
        return df,0,0,1,None
    except:
        print('Error: ', sys.exc_info()[0])
        return df,0,0,2,None

# boilerplate for parameters to pass into the CDS view
def create_CDS_filter(filters,inlinecount,orderby,select,skip,top):
    cds_params={'$filter':filters,
                '$inlinecount':inlinecount,
                '$orderby':orderby,
                '$select':select,
                '$skip':skip,
                '$top':top}
    return cds_params


# get values from config file for a view
def get_config_values(config,section,record_limit):
    #create dict of keys to store values from yaml config file
    section_keys = {'CDS_VIEW':'',
                  'ACTIVE':'',
                  'BASE_TABLE':'',
                  'STRATEGY':'',
                  'INCREMENTAL_FIELD':'',
                  'INCREMENTAL_FIELD_TYPE':'',
                  'ROW_LIMIT':0,
                  'SELECT':'',
                  'FILTER':'',
                  'SKIP':'',
                  'TOP':'',
                  'INLINE_COUNT':'',
                  'ORDER_BY':'',
                  'SNOWFLAKE_DB':'',
                  'SNOWFLAKE_SCHEMA':'',
                  'SNOWFLAKE_TABLE':''}
    #Load config values:
    selected_section = config.get(section)
    #required parameters
    #section_keys.update({'CDS_VIEW':config.get(section, 'cds_view_name')})
    section_keys.update({'CDS_VIEW':selected_section.get('cds_view_name')})
    section_keys.update({'ACTIVE':True})
    #operational parameters
    #default row limit to 100000, restrict to 100000, or take lower value, or apply testing record limit of 1000
    row_limit = 0
    row_limit += int(str(selected_section.get('row_limit')).strip() or "0")
    if record_limit == "true":
        row_limit = 1000
    elif row_limit == 0 or int(row_limit) >= 100000:
        row_limit = 100000
    section_keys.update({'ROW_LIMIT':row_limit})
    
    section_keys.update({'STRATEGY':selected_section.get('strategy')}) 
    section_keys.update({'INCREMENTAL_FIELD':selected_section.get('incremental_field')})
    section_keys.update({'BASE_TABLE':selected_section.get('base_table_name')})
    #CDS selection parameters, these are optional
    section_keys.update({'SELECT':selected_section.get('select')})
    section_keys.update({'FILTER':selected_section.get('filter')})
    section_keys.update({'SKIP':selected_section.get('skip')})
    section_keys.update({'TOP':selected_section.get('top')})
    #default inlinecount to all pages
    section_keys.update({'INLINE_COUNT':'allpages'})
    section_keys.update({'ORDER_BY':selected_section.get('orderby')})
    #snowflake table details
    section_keys.update({'SNOWFLAKE_SCHEMA':selected_section.get('snowflake_schema')})
    section_keys.update({'SNOWFLAKE_TABLE':selected_section.get('snowflake_table')})   
    section_keys.update({'SNOWFLAKE_DB':LZ_DB})
    
    return section_keys
   
# process the view using the config values from the config file
def processView(section,sap_user,client,API_KEY,APP_ID,file_out_location,api_url_part1,api_url_part2,config_values,tgt_container,CDS_view_history,archive_file):
    print("Entering Process View")
    process_status = False
    files_processed = ''
    cds_view = config_values.get('CDS_VIEW')
    row_limit = config_values.get('ROW_LIMIT')
    strategy = config_values.get('STRATEGY')
    #snowflake conn:
    sf_db = config_values.get('SNOWFLAKE_DB')
    sf_schema = config_values.get('SNOWFLAKE_SCHEMA')
    sf_table = config_values.get('SNOWFLAKE_TABLE')
    
    incremental_field = config_values.get('INCREMENTAL_FIELD')
    messages = ['get_CDS_data() method failed for {source}']
    odata_params = create_CDS_filter(config_values.get('FILTER'),
                                    config_values.get('INLINE_COUNT'),
                                    config_values.get('ORDER_BY'),
                                    config_values.get('SELECT'),
                                    config_values.get('SKIP'),
                                    config_values.get('TOP'))
    payload ={'app_id':APP_ID,
            'app_key':API_KEY,
            'sap_user':sap_user,
            '$format':FORMAT}  
    payload.update(odata_params)

    messages,process_status,files_processed,max_incremental_value,CURRENT_TIMESTAMP,Incremental_Start_Value,Incremental_End_Value,Extraction_Start_Time,Extraction_End_Time,CDS_view_history,MAX_FILE_DATE,rows_loaded = get_CDS_data(
                                                                                API_KEY,
                                                                                file_out_location,
                                                                                api_url_part1, 
                                                                                api_url_part2, 
                                                                                client, 
                                                                                payload, 
                                                                                section,
                                                                                cds_view, 
                                                                                CDS_view_history,
                                                                                row_limit,  
                                                                                strategy, 
                                                                                incremental_field,
                                                                                tgt_container,
                                                                                archive_file,
                                                                                sf_db,sf_schema,sf_table)          
    print("Exiting Process View")
    return messages,process_status,files_processed,max_incremental_value,CURRENT_TIMESTAMP,Incremental_Start_Value,Incremental_End_Value, \
        Extraction_Start_Time,Extraction_End_Time,CDS_view_history,MAX_FILE_DATE,rows_loaded

# process replay queue
def process_replay_queue(config,tgt_container,files_processed,failed_files):
    blobs_list = ContainerClient.list_blobs(tgt_container,name_starts_with= "QUEUE/")
    snowflake_write_failures = 0
    messages = []
    #print(blobs_list)
    current_time = str(datetime.datetime.now()).replace(" ","_").replace(":","_").replace(".","_")
 
    for blob in blobs_list:
        try:
            # set values
            print("Started processing file: " + blob.name + '\n')
            file_name = blob.name.replace("QUEUE/","")
            name_parse = file_name.split('.')
            cds_view = name_parse[0]
            selected_config = config.get(cds_view)
            #sf_db = selected_config.get('snowflake_db')
            sf_db = LZ_DB
            sf_schema = selected_config.get('snowflake_schema')
            sf_table = selected_config.get('snowflake_table')
            print(f'Loading data from Process Queue into SF db-{sf_db} schema-{sf_schema} table-{sf_table}')
            # download blob and write to snowflake
            blob_content = ContainerClient.download_blob(tgt_container,blob.name).readall()
            json_list = pd.read_json(blob_content.decode('utf8'),typ='series',orient='records').to_list()
            row_count = len(json_list)
            failure,return_messages = post_to_snowflake(sf_db,sf_schema,sf_table,json_list,file_name,row_count) 
            snowflake_write_failures += failure
            messages.append(return_messages)
                
            # # Log to manifest 
            files_processed = files_processed + blob.name + "," + str(0) + "\n"
            print(f'Completed processing from retry queue file: {blob.name} with {row_count} rows.')
            print(messages)
        except Exception as e:
            print (f"Error processing from retry queue: {blob.name}")
            print(e)
            failed_files = failed_files.replace("None","")
            failed_files = failed_files + file_name + " | "
            failed_files = failed_files + blob.name + "," + str(0) + "\n"

    return files_processed,failed_files,current_time

# process threads
def thread_processor(val):
    # process incoming list of variables
    config = val[0]
    section = val[1]
    record_limit = val[2]
    #file_uploader_json = val[3]
    API_KEY = val[3]
    APP_ID = val[4]
    file_out_location = val[5]
    api_url_part1 = val[6]
    api_url_part2 = val[7]
    tgt_container = val[8]
    CDS_view_history = val[9]
    archive_file = val[10]
    client = val[11]
    sap_user = val[12]

    # process the view
    failed_files = 'None'
    files_processed = ''
    messages = ''
    process_status = False
    control_table_status = 0
    Incremental_Start_Value=CURRENT_TIMESTAMP
    Incremental_End_Value=CURRENT_TIMESTAMP
    Extraction_Start_Time=CURRENT_TIMESTAMP
    Extraction_End_Time=CURRENT_TIMESTAMP
    MAX_FILE_DATE=CURRENT_TIMESTAMP
    local_Time=CURRENT_TIMESTAMP
    active_sections = {key: value for key, value in config.items() if value.get("active", "").lower() == "true"}

    update_control_table = False
    if section in active_sections:
        # get_view_params function call
        config_values = get_config_values(config,section,record_limit)
        update_control_table = True
        # process the view
        print("")
        print('Processing CDS View', section)
        messages,process_status,files_processed,max_incremental_value,local_Time,Incremental_Start_Value,Incremental_End_Value,Extraction_Start_Time,Extraction_End_Time,CDS_view_history,MAX_FILE_DATE,rows_loaded = processView(section,sap_user,client,API_KEY,APP_ID,file_out_location,api_url_part1,api_url_part2,config_values,tgt_container,CDS_view_history,archive_file)
    
    else:
        message = f'CDS view found, but not active {section}.'
        process_status = True # - id23578 - updated to not fail on inactive view.
        update_control_table = False
        max_incremental_value = 0
    
    if process_status: 
        message = f'processView(): completed for {section}: {messages}'
        if update_control_table:
            control_table_status,_control_table_msg = load_control_table(cds_view,CURRENT_TIMESTAMP,Incremental_Start_Value,Incremental_End_Value,Extraction_Start_Time,Extraction_End_Time,section,MAX_FILE_DATE,rows_loaded)
            print(f'control_table_status{control_table_status}')
    else:
        message = f'processView(): failed for {section}: {messages}.'
        print(message)
        failed_files = failed_files.replace("None","") + section + "|"
    
    return messages,process_status,files_processed,failed_files,max_incremental_value,section,local_Time,Incremental_Start_Value,Incremental_End_Value,Extraction_Start_Time,Extraction_End_Time,CDS_view_history,MAX_FILE_DATE,control_table_status

# main method with loop for all views or a single viwe call
def main(section:str,record_limit:str,use_replay_queue:str,archive_file:str,extract_type:str):
    # read config files 
    APP_ID, \
    SAP_USER, \
    api_url_part1, \
    api_url_part2, \
    config_path, \
    incremrental_path, \
    file_out_location, \
    SAP_API_KEY, \
    THREADS, \
    CLIENT = getTELToolsConfig()
    
    if extract_type.lower() == 'finance':
        SAP_cdsv_config = os.path.join(config_path,"TelTools_Sapapi_Finance.json")
    elif extract_type.lower() == 'monthly':
        SAP_cdsv_config = os.path.join(config_path,"TelTools_Sapapi_Monthly.json")
    elif extract_type.lower() == 'daily':
        SAP_cdsv_config = os.path.join(config_path,"TelTools_Sapapi_Daily.json")
    else:
        raise Exception("Error: Invalid extract_type used, exiting the code.")
    
    #read sapapi input and runtime configs config
    config = read_config_file(SAP_cdsv_config)
    if not config:
        raise Exception(f"Error while fetching Input Config")
    CDS_view_history,_msg = read_runtime_config()
    if not CDS_view_history:
        raise Exception(f"Error while fetching Runtime Config: {_msg}")
    
    # initialize vars
    failed_files = "None"
    files_processed = "FileName,RowCount\n"

    # get SAS keys from Azure Keyvault
    # sasURLTGT = TT.getAzureSecret("AZURE-STORAGE-SAPAPI-SAS-SFSA").value
    API_KEY = TT.getAzureSecret(SAP_API_KEY).value
    # create container client
    #  = ContainerClient.from_container_url(sasURLTGT)
    tgt_container = '' 
    
    config,section = inputSelection(config,section)
    # process api run
    if(use_replay_queue.lower() != "true"):
        #if no viewname is passed in, run all active views, else run singular view
        if section.upper() =='ALL' or section.upper() =='MULTI':
            #iterate through all config entries
            vals = []
            result =[]

            for section in config:
                vals.append([config,section,record_limit,API_KEY,APP_ID,file_out_location,api_url_part1,api_url_part2,tgt_container,CDS_view_history,archive_file,CLIENT,SAP_USER])
    
            with ThreadPoolExecutor(max_workers=THREADS) as exe:
                print(f'Threading max workers: {exe._max_workers}.')
                # Maps the method with a list of values.
                result = exe.map(thread_processor,vals)
     
            # process thread results
            for r in result:
                print(r[0])
                success = r[1]
                files_processed_result = r[2]
                failed_files_result = r[3]
                max_incremental_value = r[4]
                section = r[5]
                CURRENT_TIMESTAMP=r[6]
                Incremental_Start_Value=r[7]
                Incremental_End_Value=r[8]
                Extraction_Start_Time=r[9]
                Extraction_End_Time=r[10]
                cds_view=r[11]
                MAX_FILE_DATE=r[12]
                control_table_status=r[13]
                if success:
                    files_processed = files_processed + files_processed_result
                    if max_incremental_value > 0:
                        print(f'Incremental value updated for: {section} to {max_incremental_value}.')
                else:
                    failed_files = failed_files.replace("None","") + failed_files_result + "|" 

                if control_table_status:
                    if max_incremental_value > 0:
                        print(f"Failed updated max_incremental_value in ControlTable for: {section} to {max_incremental_value}")
                        failed_files = failed_files.replace("None","") + section + "|" 
        else:

            #single view run, will always run regardless if view is active or not
            print("CDS section found, running for Single section {}".format(section))
            files_processed = ''    
            process_status = False
            control_table_status = 0
            config_values = get_config_values(config,section,record_limit)
            # process the view
            print('Processing single section', section)
            messages,process_status,files_processed,max_incremental_value,CURRENT_TIMESTAMP,Incremental_Start_Value,Incremental_End_Value,Extraction_Start_Time,Extraction_End_Time,CDS_view_history,MAX_FILE_DATE,rows_loaded = processView(section,SAP_USER,CLIENT,API_KEY,APP_ID,file_out_location,api_url_part1,api_url_part2,config_values,tgt_container,CDS_view_history,archive_file)
    
            if process_status:
                temp_var=''
                print(f'Single run completed for {section}: {messages}')
                control_table_status,_control_table_msg = load_control_table(temp_var,CURRENT_TIMESTAMP,Incremental_Start_Value,Incremental_End_Value,Extraction_Start_Time,Extraction_End_Time,section,MAX_FILE_DATE,rows_loaded)
                if max_incremental_value > 0:
                    print(f'Incremental value updated for: {section} to {max_incremental_value}.')
            else:
                failed_files = files_processed 
                print(f'Single view run failed for {section}; {messages}')       

            if control_table_status:
                if max_incremental_value > 0:
                    print(f"Failed updated max_incremental_value in ControlTable for: {section} to {max_incremental_value}")
                    failed_files = failed_files.replace("None","") + failed_files_result + "|"
    else:
        # process files from replay queue
        files_processed,failed_files,CURRENT_TIMESTAMP = process_replay_queue(config,tgt_container,files_processed,failed_files)
    
    if failed_files != 'None':
        # fail the job
        failed_files = failed_files.strip("|")
        print("The following files failed: " + failed_files)
        # manifestName = "getSAPAPIFiles_" + CURRENT_TIMESTAMP + "_FailedFiles.csv"
        # manifestURL = sasURLTGT.replace("/sapapi","/sapapi/MANIFEST/"+manifestName)
        # manifestBlob = BlobClient.from_blob_url(blob_url=manifestURL)
        # manifestBlob.upload_blob(data=failed_files)
        raise Exception("Failed File Error")
    
    else: 
        # post the manifest to blob storage
        # manifestName = "getSAPAPIFiles_" + CURRENT_TIMESTAMP + ".csv"
        # manifestURL = sasURLTGT.replace("/sapapi","/sapapi/MANIFEST/"+manifestName)
        # manifestBlob = BlobClient.from_blob_url(blob_url=manifestURL)
        # manifestBlob.upload_blob(data=files_processed)
        print("Full run completed.")

if __name__ == "__main__":
    args = sys.argv[1:]
    section:str = args[0] #cds_view name
    record_limit:str = args[1].lower() #true/false - (true to limit to 1k records)
    use_replay_queue:str = args[2].lower() #true/false - to run from QUEUE blob folder
    archive_file:str = args[3].lower() #true/false
    extract_type:str = args[4].lower() #finance/monthly/daily 
    
    print(f"extractType:{extract_type}, sectionName: {section}, recordLimit: {record_limit}, useReplayQueue: {use_replay_queue}, archiveFile: {archive_file}.")
    # logging.basicConfig(level=logging.DEBUG)
    logging.debug(f"Running SAPAPI Extracts for {extract_type}...")
    main(section,record_limit,use_replay_queue,archive_file,extract_type)