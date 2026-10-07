import sys
from datetime import datetime
import logging
import requests
import os
import json
from requests.exceptions import ConnectionError
from requests.adapters import HTTPAdapter
import include.Python.TELTools as TT

#Global Parameters
SIRFIS_BASE_URL="https://apis.intel.com/supplier/sirfis/v1/"
database_name=os.getenv('SNOWFLAKE_LZ')
sf_schema_name='SIRFIS'

#Get the Bearer Token to be used for OAuth
def get_access_token():
	API_KEY = TT.getAzureSecret('SIRFIS-API-KEY').value
	SECRET = TT.getAzureSecret('SIRFIS-API-SECRET').value
	TOKEN_URL = TT.getAzureSecret('SIRFIS-API-TOKEN-URL').value
	response = requests.post(
		TOKEN_URL,
		data = {
			"grant_type": "client_credentials"
		},
		auth = (API_KEY,SECRET)
	)
	if response.status_code == 200 and 'access_token' in response.json():
		return response.json().get('access_token')
	return None
	
#Get Current Time Stamp
def get_current_timestamp():
	CURRENT_TIMESTAMP = str(datetime.now()).replace(" ","_").replace(":","_").replace(".","_")
	return CURRENT_TIMESTAMP

#Method to extract data from the API
def get_sirfis_data(session, headers = {},include_history = False,group_children=False):
	API_URL = SIRFIS_BASE_URL+"forecasts"
	extract_datetimestamp=datetime.now()
	logging.debug("Calling SIRFIS API...")
	include_history=False
	group_children=False
	response = session.get(API_URL, headers=headers, data={"includeHistory": include_history, "groupChildren": group_children})
	logging.debug("Processing response...")
	status_code = response.status_code
	if status_code == 200:
		logging.debug("{}: Successful API call".format(status_code))
		sirfis_data = json.loads(response.content)
		sirfis_data_record_count=len(sirfis_data)
		return extract_datetimestamp,sirfis_data,sirfis_data_record_count
	else:
		logging.error("API Error status code: {}".format(status_code))
		print("API Error status code: {}".format(status_code))
		print("Data Extraction for Sirfis Data Failed")
		exit(1)
		return extract_datetimestamp,0,0

#Method to load data into Snowflake and Blob Storage:
def load_sirfis_Data(session,headers_api):
    print("Load Sirfis Data")
    (extract_datetimestamp,dataset,record_count)=get_sirfis_data(session,headers_api)
    file_name='SIRFIS_'+datetime.strftime(extract_datetimestamp,"%Y-%m-%dT%H%M%S")+'.json'
    sf_table_name='SIRFIS_FORECAST'
    print(database_name)
    print(sf_schema_name)
    print(sf_table_name)
    print(file_name)
    print(extract_datetimestamp)
    print(record_count)
    try:
        return_messages = TT.putSnowflakeDataFrame(database_name,sf_schema_name,sf_table_name,dataset,file_name,extract_datetimestamp,record_count)
        return 0,return_messages
    except Exception as e:
        message = f"Snowflake Data Load for Sirfis Data failed for {file_name}: {e}"
        print(return_messages)
        return 1,return_messages

#Method to extract tool installation data from the API
def get_sirfis_too_installation_data(session, headers={}):
    SIRFIS_TOOL_API_URL = SIRFIS_BASE_URL+"installschedule"
    print(SIRFIS_TOOL_API_URL)
    extract_datetimestamp=datetime.now()
    logging.debug("Calling SIRFIS Tool Installation API...")
    response = session.get(SIRFIS_TOOL_API_URL, headers=headers)
    logging.debug("Processing response...")
    status_code = response.status_code
    if status_code == 200:
        logging.debug("{}: Successful API call".format(status_code))
        sirfis_tool_installation_data = json.loads(response.content)
        sirfis_tool_installation_data_record_count=len(sirfis_tool_installation_data)
        return extract_datetimestamp,sirfis_tool_installation_data,sirfis_tool_installation_data_record_count
    else:
        logging.error("API Error status code: {}".format(status_code))
        print("API Error status code: {}".format(status_code))
        print("Data Extraction for Sirfis Tool Installation Data Failed")
        exit(1)
        return extract_datetimestamp,0,0

def load_sirfis_tool_Data(session,headers_api):
    print("Load Sirfis Tool Installation Data")
    (extract_datetimestamp,dataset,record_count)=get_sirfis_too_installation_data(session,headers_api)
    file_name='SIRFIS_'+datetime.strftime(extract_datetimestamp,"%Y-%m-%dT%H%M%S")+'.json'
    sf_table_name='SIRFIS_TOOL_INSTALLATION'
    print(database_name)
    print(sf_schema_name)
    print(sf_table_name)
    print(file_name)
    print(extract_datetimestamp)
    print(record_count)
    try:
        return_messages = TT.putSnowflakeDataFrame(database_name,sf_schema_name,sf_table_name,dataset,file_name,extract_datetimestamp,record_count)
        return 0,return_messages
    except Exception as e:
        message = f"Snowflake Data Load for Sirfis Tool Installation Data failed for {file_name}: {e}"
        print(return_messages)
        return 1,return_messages

#Main Function to execute the extracts
def main():
    print("Creating Session")
    github_adapter = HTTPAdapter(max_retries=3)
    session = requests.Session()
    try:
        access_token=get_access_token()
    except ConnectionError as ce:
        print("Connection Error:"+ce)
    session.cookies.set("SecureCHALLENGE","YES")
    headers_api = {"Authorization": f"Bearer {access_token}"}
    load_sirfis_Data(session,headers_api)
    load_sirfis_tool_Data(session,headers_api)
    print("Task Complete!")

if __name__ == "__main__":
    main()