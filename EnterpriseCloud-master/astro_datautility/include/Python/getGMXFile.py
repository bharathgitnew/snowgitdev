
import os
import datetime
import gzip
import csv
import sys
import io
import json
import fnmatch
import pandas as pd
import numpy as np
from azure.storage.blob import BlobClient, ContainerClient, __version__
from include.Python.TELTools import putSnowflakeDataFrame, getAzureSecret, load_control_table,getFileUploaderConfig,formatFileDate
from concurrent.futures import ThreadPoolExecutor
from collections import Counter
import re
import argparse

'''
Requirements and references:
requirements
pip install azure-storage-blob
pip install snowflake-connector-python[pandas]

Server envrionment variables - SAS keys to source and target blob files:
AZURE-STORAGE-GMX-SAS-USC - source gmx storage account
AZURE-STORAGE-GMX-SAS-USR2 - source gmx storage account
AZURE-STORAGE-GMX-SAS-SFSA - target archive and error blob storage
AZURE-STORAGE-GMX-SAS-PROD - source gmx PROD storage account

refs:
https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-python?tabs=environment-variable-windows
https://docs.microsoft.com/en-us/python/api/azure-storage-blob/azure.storage.blob.containerclient?view=azure-python#azure-storage-blob-containerclient-download-blob
'''
## globals
run_timestamp = datetime.datetime.now()
RUN_TIME = formatFileDate(run_timestamp)
CURRENT_TIMESTAMP = str(run_timestamp).replace(" ","_").replace(":","_").replace(".","_")
failed_files = 'None'
tel_tools_path = '/usr/local/airflow/include/Configuration/TelTools.json'
ENV = os.environ['SNOWFLAKE_ENV']
LZ_DB = os.environ["SNOWFLAKE_LZ"]
processed_fcount_map = {}
blob_fcount_map = {}

## helper functions
# get config values from teltools.json
def getTELToolsConfig():
    # load from teltools.json
    with open(tel_tools_path,'r') as f:
        tel_tools_json = json.load(f,strict=False)
        gmx_json = tel_tools_json.get('Services').get('GMX').get(ENV)
        FILEUPLOADER_CONFIG = gmx_json.get('FILEUPLOADER_CONFIG')
        THREADS = int(gmx_json.get('THREADS'))

    return FILEUPLOADER_CONFIG,THREADS

def extract_filedatetime_from_filename(filename):
    match = re.search(r'\d{14}', filename)
    if match:
        timestamp_str = match.group()
        return datetime.datetime.strptime(timestamp_str, "%Y%m%d%H%M%S")
    else:
        return ValueError(f"No 14-digit timestamp found in filename: {filename}.")

# get filekey and elements from filename
def getFileConfigItems(file_uploader_json,newFileNameTXT):
    for fileConfig in file_uploader_json:
        fileConfigDict = file_uploader_json.get(fileConfig)
        fileMatchString = fileConfigDict.get('FILE')
        if fnmatch.fnmatch(newFileNameTXT,fileMatchString.upper()):
            db = LZ_DB
            schema = str(fileConfigDict.get('SNOWFLAKE_SCHEMA_NAME')).upper()
            tableName = str(fileConfigDict.get('SNOWFLAKE_TABLE_NAME')).upper()
            convert_columns_to_string = fileConfigDict.get('DATA_TYPE_STRING',False)
            return db,schema,tableName,convert_columns_to_string

# post gmx blob data data to snowflake
def processBlob(newFileNameTXT,blobString,db,schema,tableName,convert_columns_to_string,filedatetime):
    chunkCount = 0
    totalRowCount = 0
    failureCount = 0
    success = False
    messages = []
    default_datatype = str if convert_columns_to_string else None
    for fileChunk in pd.read_csv(blobString, sep = "\x01", chunksize=100000, engine="python", encoding='UTF_8_sig', quoting=csv.QUOTE_NONE, dtype=default_datatype):
        chunkCount += 1
        rowCount = 0
        rowCount += len(fileChunk.index)
        totalRowCount += rowCount
       
        # process to json and post chunk to snowflake
        if rowCount > 0:
            try:
                # json_list= fileChunk.apply(lambda x: json.loads(x.to_json()), axis=1).to_list()
                if convert_columns_to_string:
                    fileChunk = fileChunk.astype('string')
                json_list= fileChunk.replace({np.nan:None}).to_dict('records')
                message = putSnowflakeDataFrame(db,schema,tableName,json_list,newFileNameTXT,filedatetime,rowCount)
                message = f'processBlob() for chunk{chunkCount} and {rowCount} rows: {message}'
                print(message)
                messages.append(message)
                if 'FAIL_SIGNAL' in message: failureCount += 1
            except Exception as e:
                message = f"Error writing to snowflake: {db}, {schema}, {tableName}, {newFileNameTXT}: {e}"
                print(message)
                messages.append(message)
                failureCount += 1
    
    # if no failures and rows were processed, set success
    if failureCount == 0:
        success = True
        if totalRowCount == 0:
            message = f"No Rows in file: {newFileNameTXT}."
            print(message)
            messages.append(message)

    return messages,success,totalRowCount

# get sas keys from azure kv
def getSASKeysTarget():
    tgtAccount = "SFSA"
        
    sasKeyTGT = "AZURE-STORAGE-GMX-SAS-" + tgtAccount
    sasURLTGT = getAzureSecret(sasKeyTGT).value

    if not bool(sasURLTGT):
        raise ValueError("Target SAS key environment variables are empty")
    
    return sasURLTGT

def getSASKeysSource(key_vault_suffix):

    sasKeySRC = "AZURE-STORAGE-GMX-SAS-" + f"{key_vault_suffix}"
    sasURLSRC = getAzureSecret(sasKeySRC).value

    if not bool(sasURLSRC):
        raise ValueError("Source SAS key environment variables are empty")
    
    return sasURLSRC


# post blobs to container
def putBlob(tgtContainer,tgtFolder,blobContent):
    try:
        ContainerClient.upload_blob(tgtContainer, tgtFolder, blobContent, overwrite=True)
        return True
    except Exception as e:
        print("Upload_blob method failed:")
        print(e)
        return False

# process thread pool
def threadProcessor(val):
    srcContainer = val[0]
    folder = val[1]
    blob = val[2]
    file_uploader_json = val[3]
    newFileNameTXT = val[4]
    tgtContainer = val[5]
    errorFilePath = val[6]
    archiveFilePath = val[7]
    messages = []
    success = False
    rowCount = 0
    retries = 3
    retryCount = 0
    isUpdateControlTable = True
    extract_start_time = str(datetime.datetime.now())
    global processed_fcount_map, blob_fcount_map
    # download gmx file from blob storage
    # implement 3 retries
    while True:
        try:
            blobContent = ContainerClient.download_blob(srcContainer,blob.name).readall()
            blobBytesIO = io.BytesIO(blobContent)
            with gzip.open(blobBytesIO) as gz:
                file = gz.read()
            blobDecompress = file.decode('utf-8-sig')
            blobString = io.StringIO(blobDecompress)

            message = f'Successfull download, decompress and decode of gmx file: {blob.name}'
            print(message)
            messages.append(message)
        except Exception as e:
            blobString = False
            message = f'Failure downloading, decompressing, or decoding gmx file {blob.name}: {e}'
            print(message)
            messages.append(message)

        try:
            filedatetime = extract_filedatetime_from_filename(newFileNameTXT)
        except ValueError as e:
            filedatetime = False
            message = f"Error: {e}"
            print(message)
            messages.append(message)
    
        # get file uploader config
        try:
            db,schema,tableName,convert_columns_to_string = getFileConfigItems(file_uploader_json,newFileNameTXT)

        except Exception as e:
            db,schema,tableName,convert_columns_to_string = False, False, False, False
            message = f'getFileConfigItems() errored for {newFileNameTXT}: {e}'
            print(message)
            messages.append(message)

        # process blob if file uploader values were returned
        if db and schema and tableName and blobString and filedatetime:
            try:
                message,success,rowCount = processBlob(newFileNameTXT,blobString,db,schema,tableName,convert_columns_to_string,filedatetime)
                messages.append(message)
            except Exception as e:
                message = f'processBlob() errored for: {newFileNameTXT}: {e}'
                print(message)
                messages.append(message)
        else: 
            message = f'No blob file content or fileuploader config or filedatetime values returned for {newFileNameTXT}, file not processed'
            messages.append(message)

        if retryCount < retries and not success:
            retryCount += 1
            message = f'threadProcessor() did not succeed for {newFileNameTXT}, retrying.'
            print(message)
            messages.append(message)
            continue
        else: 
            break


    # log errors to raise failure later
    if not success:
        putBlob(tgtContainer, errorFilePath, blobContent)
        messages.append(f'Blob file {newFileNameTXT} failed and uploaded to Error folder.')
        return messages,success,newFileNameTXT,rowCount,isUpdateControlTable
    else:
        #Archive success blob to our own container
        #insert in control table starts
        extract_end_time = str(datetime.datetime.now())
        
        if tableName not in processed_fcount_map:
            processed_fcount_map[tableName] = {"file_count": 0, "row_count": 0, 'start_time':extract_start_time}
        
        processed_fcount_map[tableName]["file_count"] += 1
        processed_fcount_map[tableName]["row_count"] += rowCount
        
        print(f"processed_fcount_map:{processed_fcount_map}")
        
        if blob_fcount_map[tableName] == processed_fcount_map[tableName]["file_count"]:
            print(f"Processing for {tableName} completed")
            load_control_table_status = load_control_table(
                                        CURRENT_TIMESTAMP=formatFileDate(filedatetime),
                                        Incremental_Start_Value=RUN_TIME,
                                        Incremental_End_Value=extract_end_time,
                                        Extraction_Start_Time=processed_fcount_map[tableName]["start_time"],
                                        Extraction_End_Time=extract_end_time,
                                        table_name=tableName,
                                        MAX_FILE_DATE=folder,
                                        rows_loaded=str(processed_fcount_map[tableName]["row_count"]),
                                        schema=schema,
                                        db=db
                                        )
            if not load_control_table_status["status"]:
                isUpdateControlTable = False
                messages.append(load_control_table_status["message"])

        #insert in control table ends

        if "QUEUE" not in folder:
            if rowCount > 0:
                putBlob(tgtContainer, archiveFilePath, blobContent)
                message = f'Blob file {newFileNameTXT} processed {rowCount} rows and uploaded to Archive.'
                messages.append(message)
            else: 
                message = f'Blob file {newFileNameTXT} had no rows.'
                messages.append(message)
    
    return messages,success,newFileNameTXT,rowCount,isUpdateControlTable
        
def main (srcAccount:str, runType:str, configPath:str, threadNum:int=8, connection_hook: ContainerClient = ''):
    
    ## vars
    filesUnprocessed = "None"
    filesProcessed = "FileName,RowCount\n"
    print("Target container: " + srcAccount)   
    
    #select QUEUE folder based on environment
    queue_folder = "QUEUE_PROD/" if ENV == "PROD" else "QUEUE_NONPROD/"

    runTypeFolders = {
        "QUEUE": [queue_folder],
        "DAILY": ["US/"],
        #"COMMON": ["Common/"],
        "ON_DEMAND": ["USOndemand/"]
    }

    folderList = runTypeFolders.get(runType)

    # get configs
    FILEUPLOADER_CONFIG = configPath
    THREADS = threadNum
    file_uploader_json=getFileUploaderConfig(FILEUPLOADER_CONFIG)

    # get SAS keys from env variables
    sasURLTGT = getSASKeysTarget()
    tgtContainer = ContainerClient.from_container_url(sasURLTGT)

    if srcAccount == "PROD" and connection_hook:
        srcContainer = connection_hook

    elif runType == "QUEUE":
        account = "SFSA"
        sasURLSRC = getSASKeysSource(account)
        srcContainer = ContainerClient.from_container_url(sasURLSRC)

    else:
        raise ValueError("No connection hook provided and runType condition not satisfied.")
     
    file_counter = []
    for folder in folderList:
        vals = []
        result = []
        fileCount = 0
        print(f'Begin processing folder: {folder}')
        blobs_list = ContainerClient.list_blobs(srcContainer,name_starts_with= folder)
        
        for blob in blobs_list:
            # Skip files with ".keep" extension
            if "QUEUE" in folder and blob.name.endswith(".keep"):
                continue
            fileCount += 1
            fileName = blob.name.replace(folder,"")
            newFileNameTXT = fileName.replace(".gz","").upper()
            base_name = newFileNameTXT.rsplit('_', 1)[0]
            archiveFilePath =  f"ARCHIVE/{CURRENT_TIMESTAMP}/{fileName}"
            errorFilePath =  f"ERROR/{CURRENT_TIMESTAMP}/{fileName}"
            # set arguments for threadpool processor
            vals.append([srcContainer,folder,blob,file_uploader_json,newFileNameTXT,tgtContainer,errorFilePath,archiveFilePath])
            file_counter.append(base_name)
            
        counter = Counter(file_counter)
        print(f"{counter=}")
        for key,val in counter.items():
            try:
                _,_,tableName,_ = getFileConfigItems(file_uploader_json,key)
            except Exception as e:
                _,_,tableName,_ = False, False, False, False
            if tableName:
                blob_fcount_map[tableName] = counter[key]
        print(f'blob_fcount_map:{blob_fcount_map}')
        
        # two executions of threadpool processor, one for each folder
        with ThreadPoolExecutor(max_workers=THREADS) as exe:
            print(f'Threading max workers: {exe._max_workers}.')
            # Maps the method with a list of values.
            result = exe.map(threadProcessor,vals)
     
        # process thread results
        for r in result:
            print(r[0])
            success = r[1]
            processedFileName = r[2]
            rowCount = r[3]
            if success:
                # Log to manifest 
                filesProcessed = filesProcessed + processedFileName + "," + str(rowCount) + "\n"
            else:
                filesUnprocessed = filesUnprocessed.replace("None","") + processedFileName + "|"
        print(f'Completed processing {fileCount} files in folder {folder}.')

    # post the manifest to blob storage
    manifestName = "getGMXFiles_" + CURRENT_TIMESTAMP + ".csv"
    manifestURL = sasURLTGT.replace("/gmx","/gmx/MANIFEST/"+manifestName)
    manifestBlob = BlobClient.from_blob_url(blob_url=manifestURL)
    manifestBlob.upload_blob(filesProcessed)
            
    # raise error if any files failed to load, deliver message on which files failed.
    if filesUnprocessed != "None":
        filesUnprocessed = filesUnprocessed.strip()
        filesUnprocessed = filesUnprocessed.strip("|")
        print("Files not processed: " + filesUnprocessed)
        manifestName = "getGMXFiles_" + CURRENT_TIMESTAMP + "_UnProcessedFiles.csv"
        manifestURL = sasURLTGT.replace("/gmx","/gmx/MANIFEST/"+manifestName)
        manifestBlob = BlobClient.from_blob_url(blob_url=manifestURL)
        manifestBlob.upload_blob(filesUnprocessed)
        raise Exception("Failed file error.")
    else:
        print("Full run completed, no errors.")

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Run data process")

    parser.add_argument("srcAccount", type=str, help="Source account")
    parser.add_argument("runType", type=str, help="Run type")
    parser.add_argument("configPath", type=str, help="Path to config file")
    parser.add_argument("threadNum", type=int, help="Number of threads")
    parser.add_argument(
        "--connection_hook",
        type=str,
        default="",
        help="Optional connection hook (default: empty string)"
    )

    args = parser.parse_args()

    main(
        args.srcAccount,
        args.runType.upper(),
        args.configPath,
        args.threadNum,
        args.connection_hook
    )