#Import necessary libraries
import msal
import requests
import json
import pandas as pd
from datetime import date, timedelta
import include.Python.TELTools as TT
import os
import io
from azure.storage.blob import BlobClient, ContainerClient, __version__
import numpy as np
from datetime import datetime
from datetime import timedelta
import sys

def get_lastrunTime(view_name):
    try:
        database_name=os.getenv('SNOWFLAKE_LZ')
        schema_name="POWERBI"
        table_name=view_name
        activity_Date,messages = TT.readControlTable(database_name,schema_name,table_name)
        activity_Date = datetime.strptime(activity_Date,'%Y-%m-%d')
        print("Successful Extraction "+ str(activity_Date))
        return activity_Date,messages,0
    except Exception as e:
        msg = "Failed to fetch Last Run Time from Snowflake"
        return 0,msg,1

#Set Client ID and Secret for Service Principal
def get_keyvault_data():
    try:
        client_id = TT.getAzureSecret('POWERBI-APP').value
        client_secret = TT.getAzureSecret('POWERBI-SECRETVALUE').value
        tenant_id = TT.getAzureSecret('POWERBI-TENANTID').value
        msg="Success"
        return client_id,client_secret,tenant_id,msg,0
    except Exception as e:
        msg = "Failed to fetch Client Secret from KeyVault"
        return 0,0,0,msg,1

def set_url_details(view_name):
    try:
        client_id,client_secret,tenant_id,msg,status=get_keyvault_data()
        authority_url = "https://login.microsoftonline.com/"+tenant_id
        scope = ["https://analysis.windows.net/powerbi/api/.default"]
        #Set Power BI REST API to get Activities for today
        activity_Date,messages,status=get_lastrunTime(view_name)
        activity_Date = activity_Date.strftime("%Y-%m-%d")
        base_url="https://api.powerbi.com/v1.0/myorg/admin/"
        return client_id,client_secret,tenant_id,authority_url,scope,base_url,activity_Date,msg,0
    except Exception as e:
        msg = "Failed to Set URL Details"
        return 0,0,0,0,0,0,0,msg,1    
#Use MSAL to grab token

def grab_token(view_name):
    client_id,client_secret,tenant_id,authority_url,scope,base_url,activity_Date,msg,status=set_url_details(view_name)
    try:
        app = msal.ConfidentialClientApplication(client_id, authority=authority_url, client_credential=client_secret)
        result = app.acquire_token_for_client(scopes=scope)
        return result,base_url,activity_Date,0
    except Exception as e:
        msg = "Failed to fetch Access Token"+str(e)
        return msg,base_url,0,1


def get_config_details():
    with open("/usr/local/airflow/include/Configuration/TelTools_PowerBILogs.json", "r") as f:
        config = json.load(f)
        datasets = config.get('POWERBILOGS', {})
        return datasets

def get_data(view_name):
    datasets=get_config_details()
    if view_name=="ALL":
        for i in datasets:
            get_pbilogs(datasets[i].get('snowflake_table'))
    else:
        for i in datasets:
            if(view_name==datasets[i].get('snowflake_table')):
                get_pbilogs(datasets[i].get('snowflake_table'))

def get_pbilogs(view_name):
    database_name=os.getenv('SNOWFLAKE_LZ')
    sf_schema_name='POWERBI'
    sf_table_name=view_name
    result,base_url,activity_Date,status=grab_token(view_name)
    json_list=[]
    json_list1=[]
    #try:
# #Get latest Power BI Activities
    if view_name=='ACTIVITY':
        url =str(base_url) + "activityevents?startDateTime='" + str(activity_Date) + "T00:00:00'&endDateTime='" + str(activity_Date) + "T23:59:59'"
        if 'access_token' in result:
            json_list=[]
            json_list1=[]
            access_token = result['access_token']
            header = {'Content-Type':'application/json', 'Authorization':f'Bearer {access_token}'}
            api_call = requests.get(url=url, headers=header,verify=False)

            #Set continuation URL
            contUrl = api_call.json()['continuationUri']
            
            #Get all Activities for first hour, save to dataframe (df1) and append to empty created df
            result = api_call.json()['activityEventEntities']
            json_data=json.dumps(result)
            data=json.loads(json_data)
            dfs=pd.json_normalize(data)
            json_list= dfs.apply(lambda x: json.loads(x.to_json()), axis=1).to_list()
            while contUrl is not None:        
                api_call_cont = requests.get(url=contUrl, headers=header,verify=False)
                contUrl = api_call_cont.json()['continuationUri']
                result = api_call_cont.json()['activityEventEntities']
                json_data1=json.dumps(result)
                data1=json.loads(json_data1)
                dfs1=pd.json_normalize(data1)
                json_list1= dfs.apply(lambda x: json.loads(x.to_json()), axis=1).to_list()
            record_count=len(json_list)
            record_count1=len(json_list1)
            file_name="ACTIVITY"+str(activity_Date)+".json"
            extract_datetimestamp=str(activity_Date)+"T00:00:00"
            return_messages = TT.putSnowflakeDataFrame(database_name,sf_schema_name,sf_table_name,json_list,file_name,extract_datetimestamp,record_count)
            print("Data Loaded to Snowflake")
            return_messages1 = TT.putSnowflakeDataFrame(database_name,sf_schema_name,sf_table_name,json_list1,file_name,extract_datetimestamp,record_count1)
            print("Data Loaded to Snowflake")
            CURRENT_TIMESTAMP=str(datetime.now()).replace(" ","_").replace(":","_").replace(".","_")
            Incremental_Start_Value=activity_Date
            Incremental_End_Value= datetime.strptime(activity_Date,'%Y-%m-%d')+ timedelta(days=1)
            Incremental_End_Value=datetime.strptime(str(Incremental_End_Value)[0:10],'%Y-%m-%d')
            Incremental_End_Value=str(Incremental_End_Value)[0:10]
            Extraction_Start_Time=CURRENT_TIMESTAMP
            Extraction_End_Time=CURRENT_TIMESTAMP
            total_record_count = record_count+record_count1
            controload_message =  TT.loadControlTable(database_name,sf_schema_name,CURRENT_TIMESTAMP,Incremental_Start_Value,Incremental_End_Value,Extraction_Start_Time,Extraction_End_Time,sf_table_name,CURRENT_TIMESTAMP,total_record_count)
            print("Data Extraction Complete")
            return json_list,'success',0
        else:
            msg = "Failed to fetch Access Token"
            return json_list,msg,1
    elif view_name=='GATEWAYS':
        if 'access_token' in result:
            json_list=[]
            json_list1=[]
            access_token = result['access_token']
            header = {'Content-Type':'application/json', 'Authorization':f'Bearer {access_token}'}
            url=str(base_url)+view_name.lower()
            api_call = requests.get(url=url, headers=header,verify=False)
            result1 = api_call.json()
            json_data=json.dumps(result1)
            data=json.loads(json_data)
            dfs=pd.json_normalize(data)
            json_list= dfs.apply(lambda x: json.loads(x.to_json()), axis=1).to_list()
            record_count=len(json_list)
            file_name=str(view_name)+str(activity_Date)+".json"
            extract_datetimestamp=str(activity_Date)+"T00:00:00"
            return_messages = TT.putSnowflakeDataFrame(database_name,sf_schema_name,sf_table_name,json_list,file_name,extract_datetimestamp,record_count)
            print("Gateways Data Loaded to Snowflake")
            CURRENT_TIMESTAMP=str(datetime.now()).replace(" ","_").replace(":","_").replace(".","_")
            Incremental_Start_Value=activity_Date
            Incremental_End_Value= datetime.strptime(activity_Date,'%Y-%m-%d')+ timedelta(days=1)
            Incremental_End_Value=datetime.strptime(str(Incremental_End_Value)[0:10],'%Y-%m-%d')
            Incremental_End_Value=str(Incremental_End_Value)[0:10]
            Extraction_Start_Time=CURRENT_TIMESTAMP
            Extraction_End_Time=CURRENT_TIMESTAMP
            controload_message =  TT.loadControlTable(database_name,sf_schema_name,CURRENT_TIMESTAMP,Incremental_Start_Value,Incremental_End_Value,Extraction_Start_Time,Extraction_End_Time,sf_table_name,CURRENT_TIMESTAMP,record_count)
            print("Gateways Data Loaded to Control Table")
            for item in json_list:
                sf_table_name2='DATASOURCES'
                for subitem in item["value"]:
                    print(subitem["id"])
                    json_list2=[]
                    json_list3=[]
                    access_token = result['access_token']
                    header = {'Content-Type':'application/json', 'Authorization':f'Bearer {access_token}'}
                    url=str(base_url)+view_name.lower()+"/"+subitem["id"]+"/datasources"
                    api_call = requests.get(url=url, headers=header,verify=False)
                    result2 = api_call.json()
                    json_data1=json.dumps(result2)
                    data1=json.loads(json_data1)
                    dfs1=pd.json_normalize(data1)
                    json_list2= dfs1.apply(lambda x: json.loads(x.to_json()), axis=1).to_list()
                    record_count2=len(json_list2)
                    file_name2=str(view_name)+"_"+str(subitem["id"])+"_DataSources_"+str(activity_Date)+".json"
                    extract_datetimestamp2=str(activity_Date)+"T00:00:00"
                    return_messages = TT.putSnowflakeDataFrame(database_name,sf_schema_name,sf_table_name2,json_list2,file_name2,extract_datetimestamp2,record_count2)
                    print("Data Loaded to Snowflake")
                    CURRENT_TIMESTAMP2=str(datetime.now()).replace(" ","_").replace(":","_").replace(".","_")
                    Incremental_Start_Value2=activity_Date
                    Incremental_End_Value2= datetime.strptime(activity_Date,'%Y-%m-%d')+ timedelta(days=1)
                    Incremental_End_Value2=datetime.strptime(str(Incremental_End_Value2)[0:10],'%Y-%m-%d')
                    Incremental_End_Value2=str(Incremental_End_Value2)[0:10]
                    Extraction_Start_Time2=CURRENT_TIMESTAMP2
                    Extraction_End_Time2=CURRENT_TIMESTAMP2
                    controload_message =  TT.loadControlTable(database_name,sf_schema_name,CURRENT_TIMESTAMP2,Incremental_Start_Value2,Incremental_End_Value2,Extraction_Start_Time2,Extraction_End_Time2,sf_table_name2,CURRENT_TIMESTAMP,record_count2)
            print("Data Extraction Complete")
            return json_list,'success',0
        else:
            msg = "Failed to fetch Access Token"
            return json_list,msg,1
    elif view_name=='GROUPS':
        if 'access_token' in result:
            json_list=[]
            json_list1=[]
            access_token = result['access_token']
            header = {'Content-Type':'application/json', 'Authorization':f'Bearer {access_token}'}
            url="https://api.powerbi.com/v1.0/myorg/"+view_name.lower()
            api_call = requests.get(url=url, headers=header,verify=False)
            result1 = api_call.json()
            json_data=json.dumps(result1)
            data=json.loads(json_data)
            dfs=pd.json_normalize(data)
            json_list= dfs.apply(lambda x: json.loads(x.to_json()), axis=1).to_list()
            record_count=len(json_list)
            file_name=str(view_name)+str(activity_Date)+".json"
            extract_datetimestamp=str(activity_Date)+"T00:00:00"
            return_messages = TT.putSnowflakeDataFrame(database_name,sf_schema_name,sf_table_name,json_list,file_name,extract_datetimestamp,record_count)
            print("Groups Data Loaded to Snowflake")
            CURRENT_TIMESTAMP=str(datetime.now()).replace(" ","_").replace(":","_").replace(".","_")
            Incremental_Start_Value=activity_Date
            Incremental_End_Value= datetime.strptime(activity_Date,'%Y-%m-%d')+ timedelta(days=1)
            Incremental_End_Value=datetime.strptime(str(Incremental_End_Value)[0:10],'%Y-%m-%d')
            Incremental_End_Value=str(Incremental_End_Value)[0:10]
            Extraction_Start_Time=CURRENT_TIMESTAMP
            Extraction_End_Time=CURRENT_TIMESTAMP
            controload_message =  TT.loadControlTable(database_name,sf_schema_name,CURRENT_TIMESTAMP,Incremental_Start_Value,Incremental_End_Value,Extraction_Start_Time,Extraction_End_Time,sf_table_name,CURRENT_TIMESTAMP,record_count)
            print("Groups Data Loaded to Control Table")
            print("Data Extraction Complete")
            return json_list,'success',0
        else:
            msg = "Failed to fetch Access Token"
            return json_list,msg,1
    else:
        if 'access_token' in result:
            json_list=[]
            json_list1=[]
            access_token = result['access_token']
            header = {'Content-Type':'application/json', 'Authorization':f'Bearer {access_token}'}
            url=str(base_url)+view_name.lower()
            api_call = requests.get(url=url, headers=header,verify=False)
            result = api_call.json()
            json_data=json.dumps(result)
            data=json.loads(json_data)
            dfs=pd.json_normalize(data)
            json_list= dfs.apply(lambda x: json.loads(x.to_json()), axis=1).to_list()
            record_count=len(json_list)
            file_name=str(view_name)+str(activity_Date)+".json"
            extract_datetimestamp=str(activity_Date)+"T00:00:00"
            return_messages = TT.putSnowflakeDataFrame(database_name,sf_schema_name,sf_table_name,json_list,file_name,extract_datetimestamp,record_count)
            print("Data Loaded to Snowflake")
            CURRENT_TIMESTAMP=str(datetime.now()).replace(" ","_").replace(":","_").replace(".","_")
            Incremental_Start_Value=activity_Date
            Incremental_End_Value= datetime.strptime(activity_Date,'%Y-%m-%d')+ timedelta(days=1)
            Incremental_End_Value=datetime.strptime(str(Incremental_End_Value)[0:10],'%Y-%m-%d')
            Incremental_End_Value=str(Incremental_End_Value)[0:10]
            Extraction_Start_Time=CURRENT_TIMESTAMP
            Extraction_End_Time=CURRENT_TIMESTAMP
            controload_message =  TT.loadControlTable(database_name,sf_schema_name,CURRENT_TIMESTAMP,Incremental_Start_Value,Incremental_End_Value,Extraction_Start_Time,Extraction_End_Time,sf_table_name,CURRENT_TIMESTAMP,record_count)
            print("Data Extraction Complete")
            return json_list,'success',0
        else:
            msg = "Failed to fetch Access Token"
            return json_list,msg,1
def main(view_name):
    get_data(view_name)
if __name__ == "__main__":
    args = sys.argv[1:]
    view_name:str = args[0]
    main(view_name)