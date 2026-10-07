from azure.storage.blob import ContainerClient
import os
from datetime import datetime,timezone
import json
from include.Python.TELTools import getAzureSecret, putSnowflakeDataFrame
import pandas as pd
from io import StringIO
import re

def getTime():
    currentTime = datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S+00:00')
    currentTime = datetime.strptime(currentTime,'%Y-%m-%d %H:%M:%S+00:00')
    currentTime = currentTime.replace(tzinfo=timezone.utc)
    return currentTime

def replace_special_chars_from_datetime(dt):
    return re.sub(r'[ :-]', '_', dt.strftime("%Y-%m-%d %H:%M:%S") )

def camel_to_snake_case(fileName):
    return re.sub(r'(?<!^)([A-Z])', r'_\1', fileName).upper()

def getRunTimeConfig(file_path_name):
    if os.path.exists(file_path_name):
        with open(file_path_name) as config_file:
            return json.load(config_file)
    else:
        return {}

def ExtractBlob(blob,srcContainer,tableName,currentTime,fileName):
    try:
        blobContent = ContainerClient.download_blob(srcContainer,blob.name).readall()
        decoded_content = StringIO(blobContent.decode("utf-8"))
        messages = putSnowflakeDataFrame(
            db = os.getenv('SNOWFLAKE_LZ'),
            schema = 'MSDYNAMICS',
            tableName = camel_to_snake_case(tableName),
            df = pd.read_csv(decoded_content),
            fileDate = currentTime,
            fileName = fileName
        )

        if 'FAIL_SIGNAL' in messages:
            return False , f'Failed to Upload to Snowflake for the Load :: {fileName} and Table :: {tableName}'
        else:
            return True, f"Sucessfully Downloaded :: {fileName} and Uploaded to Table :: {tableName}" 
    except Exception as e:
        return False, f"Error downloading: {blob.name}"

def main():
    Errors = []
    date_tc = None

    currentTime = getTime()
    fileNameDate = replace_special_chars_from_datetime(currentTime)
    print("execution started at\t" + str(currentTime))
    
    file_path_name = getAzureSecret("MS-DYNAMICS-FILE-PATH-NAME").value
    sas_url = getAzureSecret("MS-DYNAMICS-BLOB-CONNECTION-STRING").value
    srcContainer = ContainerClient.from_container_url(sas_url)

    incremental_data = getRunTimeConfig(file_path_name)
    
    for table_name, previous_date in incremental_data.items():
        print("Previous run for " + table_name + "\t" + previous_date)
        target = "csv/"+table_name+"/"
        blobs_list = ContainerClient.list_blobs(srcContainer,name_starts_with = target)
        for blob in blobs_list:
            if previous_date != "":
                date_tc = datetime.strptime(previous_date,'%Y-%m-%d %H:%M:%S+00:00')
                date_tc = date_tc.replace(tzinfo=timezone.utc)
            if  date_tc == None or blob.last_modified > date_tc and blob.last_modified <= currentTime:
                print("Blob name: " + blob.name + "\t" + blob.last_modified.strftime('%Y-%m-%d %H:%M:%S+00:00'))
                file_name = f'{camel_to_snake_case(table_name)}_{fileNameDate}.csv'
                result, message = ExtractBlob(
                    blob = blob,
                    srcContainer = srcContainer,
                    currentTime = currentTime,
                    tableName = table_name,
                    fileName = file_name
                )
                if result:
                    latest_date = currentTime.strftime('%Y-%m-%d %H:%M:%S+00:00')
                    incremental_data[table_name] = latest_date
                    print(message)
                else:
                    Errors.append(message)
            else:
                print("Ignoring:\t"+ blob.name + "\t" + blob.last_modified.strftime('%Y-%m-%d %H:%M:%S+00:00'))

    if bool(incremental_data):
        incremental_object = json.dumps(incremental_data, indent=1)
        with open(file_path_name, "w") as outfile:
            outfile.write(incremental_object)
    else:
        print("file doesn't exist or there are no record in file")

    if Errors:
        print('\n'.join(Errors))
        raise Exception('Data Extraction Failed!')
    else:
        print("Data Extraction Sucessfull!!! ")
        print(incremental_data)

if __name__ == "__main__":
    main()