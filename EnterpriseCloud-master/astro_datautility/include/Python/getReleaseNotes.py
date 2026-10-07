import os
import base64
import requests
import csv
import include.Python.TELTools as TT
from azure.storage.blob import BlobClient, ContainerClient, __version__
from datetime import datetime
import io
import json

# Set up your variables
org_url = "https://dev.azure.com/tokyoelectron"
project_name = "EnterpriseDataWarehouse"
repository_name='EnterpriseCloud'
pull_request_site='pullrequests?api-version=7.1&$top=100&$skip=0&status=Completed&targetRefName=refs/heads/release'
PAT = TT.getAzureSecret('AZURE-DEVOPS-RELEASENOTES').value
database_name=os.getenv('SNOWFLAKE_LZ')
sf_schema_name='AZURE_DEVOPS'
sf_table_name='PULL_REQUESTS'

#Method to extract data from Azure Devops:
def get_Data():
    headers = {}
    extract_datetimestamp = datetime.now()
    if PAT is not None:
        headers['Authorization'] = 'Basic ' + base64.b64encode(bytes(':' + PAT, 'utf-8')).decode('ascii')
        headers['Content-Type'] = 'application/json'
        headers['Accept'] = 'application/json'
    # Get all the pull requests in the project
    response = requests.get(f"{org_url}/{project_name}/_apis/git/repositories/{repository_name}/{pull_request_site}", headers=headers)
    response.raise_for_status()
    pull_requests = response.json()["value"]
    return(extract_datetimestamp,pull_requests,len(pull_requests))

#Method to load data into Snowflake and Blob Storage:
def load_Data():
    (extract_datetimestamp,pull_requests,record_count)=get_Data()
    file_name='Pull_Requests_'+datetime.strftime(extract_datetimestamp,"%Y-%m-%dT%H%M%S")+'.json'
    return_messages = TT.putSnowflakeDataFrame(database_name,sf_schema_name,sf_table_name,pull_requests,file_name,extract_datetimestamp,record_count)

#Main Method
def main():
    print("In main function now")
    load_Data()

if __name__ == "__main__":
    main()