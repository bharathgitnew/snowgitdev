import requests
import include.Python.TELTools as TT
import sys
import json
import pandas as pd
from azure.storage.blob import BlobClient, ContainerClient, __version__
import os
from datetime import datetime
from datetime import timedelta
import numpy as np
import io
import re


connector_config_path='/usr/local/airflow/include/Configuration/TelTools_Knowbe4_Connectors.json'

#Get the API Key to be used for OAuth
def get_access_token(input_string):
    try:
        API_KEY = TT.getAzureSecret(input_string).value
        print("Got the API Token Successfully")
    except ConnectionError as ce:
        print("Error in Connecting to Azure KeyVault, Please Retry")
        print("Connection Error:"+ce)
    return API_KEY

#Get Current Time Stamp
def get_current_timestamp():
	CURRENT_TIMESTAMP = str(datetime.datetime.now()).replace(" ","_").replace(":","_").replace(".","_")
	return CURRENT_TIMESTAMP

# Read Config Entries to Build the Iterator Module
def get_connectors(connector_config_path):
    with open(connector_config_path) as json_data:
         connector_data=json.load(json_data)
         conn_string=pd.DataFrame(connector_data)
         json_data.close()
    database_name=os.getenv('SNOWFLAKE_LZ')
    sf_schema_name='KNOWBE4'
    data_extract(conn_string,database_name,sf_schema_name)

#Data Extraction
def data_extract(conn_data,database_name,sf_schema_name):
    for row in conn_data:
        data_config_path='/usr/local/airflow/include/Configuration/TelTools_Knowbe4_'+str(row)+'.json'
        data_base_url = conn_data[row].Base_URL
        data_access_token = get_access_token("Knowbe4-"+str(row))
        with open(data_config_path) as json_data:
            data_loop=json.load(json_data)
            data_string=pd.DataFrame(data_loop)
            for data_row in data_string:
                number_of_objects=len(data_string[data_row])
                print(number_of_objects)
                row_count=1
                for row_count in range(1,number_of_objects+1):
                    site_name=(data_string[data_row]['DataSet'+str(row_count)]['site-url'])
                    sf_table_name=(data_string[data_row]['DataSet'+str(row_count)]['sftablename'])
                    row_count+=1
                    print(site_name)
                    full_url=data_base_url+site_name
                    print("Printing Full URL:" + full_url)
                    headers = {'Accept': 'application/json',
                                'Authorization': f'Bearer {data_access_token}'}
                    response = requests.get(full_url,headers=headers)
                    json_data=json.dumps(response.json())
                    data=json.loads(json_data)
                    dfs=pd.json_normalize(data)
                    json_list= dfs.apply(lambda x: json.loads(x.to_json()), axis=1).to_list()
                    record_count=len(json_list)                        
                    current_date=datetime.now()
                    file_name=site_name + '_1_'+datetime.strftime(current_date,"%Y-%m-%dT%H%M%S")+'.json'
                    extract_datetimestamp = current_date
                    return_messages = TT.putSnowflakeDataFrame(database_name,sf_schema_name,sf_table_name,json_list,file_name,extract_datetimestamp,record_count)

   #Recipient List can only be pulled based of the pst_ids received in the list from security tests extract, so once we recieve the list of all security tests, we have to loop through all the pst_ids in that list to be able to pull through the recipient information for the same
                    if(site_name=='phishing/security_tests'):
                        for i in range(1,len(dfs)):
                            full_url_recipeient=data_base_url+site_name+"/"+str(dfs.at[i,'pst_id'])+"/recipients"
                            sf_table_name_recipeient='REPORTING_PHISHING_SECURITY_TESTS_RECIPIENTS'
                            site_name_recipient=site_name+"/"+str(dfs.at[i,'pst_id'])+"/recipients"
                            headers = {'Accept': 'application/json',
                                        'Authorization': f'Bearer {data_access_token}'}
                            print("Printing Full URL:" + full_url_recipeient)
                            response_recipeient = requests.get(full_url_recipeient,headers=headers)
                            json_data_recipeient=json.dumps(response_recipeient.json())
                            data_recipeient=json.loads(json_data_recipeient)
                            dfs_recipeient=pd.json_normalize(data_recipeient)
                            json_list_recipeient= dfs_recipeient.apply(lambda x: json.loads(x.to_json()), axis=1).to_list()
                            record_count_recipeient=len(json_list_recipeient)
                            current_date=datetime.now()
                            file_name_recipeient=str(dfs.at[i,'pst_id'])+'_recipients'+'_1_'+datetime.strftime(current_date,"%Y-%m-%dT%H%M%S")+'.json'
                            extract_datetimestamp = current_date
                            return_messages = TT.putSnowflakeDataFrame(database_name,sf_schema_name,sf_table_name_recipeient,json_list_recipeient,file_name_recipeient,extract_datetimestamp,record_count_recipeient)

                    if response.status_code != 200:
                        print('error: ' + str(response.status_code))
                    else:
                        print('User List Loaded Successfully')
def main():
    print("In main function now")
    get_connectors(connector_config_path)

if __name__ == "__main__":
    main()