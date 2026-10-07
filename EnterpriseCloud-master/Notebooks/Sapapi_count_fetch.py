import requests
import pandas as pd
import json
from datetime import datetime
import re
import os

def getFileList(path):
    # get file list for path
    filesList = []
    for x in os.listdir(path):
        z = x.upper()
        if z.endswith('.SQL') and z.startswith('ZCDV'):
            filesList.append(path + "\\" + x)
    return filesList

repo_path = "C:\\Repo\\EnterpriseCloud\\dbt\\lz_to_ods\\models\\sapapi" 
filesList = getFileList(repo_path)
# Assign absolute URL to variable SERVICE_URL and call the get request with authentication details with header Prefer: odata.maxpagesize=500,odata.track-changes
# Header Prefer: odata.track-changes only for delta capable extractors

base_table_name_list = []
count_api_list = []
for file in filesList:
    tablename = file.replace("C:\Repo\EnterpriseCloud\dbt\lz_to_ods\models\sapapi\\",'').replace(".sql",'')
    base_table_name = re.sub('(?<=\\d{3}.).*','',tablename)
    base_table_name = base_table_name.rstrip(base_table_name[-1])
    
    # basename = re.search('(?<=\\d{3}.).*', tablename).group(0)

    base_table_name_list.append(tablename)
    #*****************API Call****************
    SERVICE_URL = """http://stg-cdsv-odata-3scale-apicast-production.apps.west.cl.ocp.tel.com/v1/odata/client224/sap/opu/odata/sap/"""+base_table_name+"""_CDS/"""+base_table_name+"""?app_id=f507a79b&app_key=564a71bc3a18bd04a18f5a7cf33c293b&sap_user=IF_API_SNOWF&$format=json&$filter=&$inlinecount=allpages&$orderby=&$select=&$skip=&$top=0"""
    response = requests.get(SERVICE_URL, headers = {"Prefer": "odata.maxpagesize=500","Prefer": "odata.track-changes"})

    # # load JSON response Python dictionary object 
    init_json = json.loads(response.content)
    count_api_list.append(init_json['d']['__count'])

    # print(count_api_list)
    

keys = base_table_name_list
values = count_api_list
dictionary_count = {}

for key, value in zip(keys, values):
    dictionary_count[key] = value

  #*****************API Call****************
df_count = pd.DataFrame(dictionary_count.items(), columns=['TableName', 'Count'])
df_count.reset_index(drop=True)
df_count.to_csv('count_sapapi.csv', encoding='utf-8')


































# Detrmine the length of Python dictionary 
# length = len(init_json['d']['results'])


# Declare two list l_record to capture indivisual record & l_output to capture complete output.
# l_output = []
# l_record = []

# # Create & append header row
# l_record = ('MANDT','ANLAGE','SPARTE','VSTELLE','ABLSPERR','BAPERTYP','ANSCHREI','SPEBENE','DRCKSTUF','ANLART','BEZUG','ABLESARTST','NODISCONCT','SERVICE','DEREGSTAT','INFOREL','ETIMEZONE','OUCONT','ERDAT','ERNAM','AEDAT','AENAM','BEGRU','LOEVM','UPDMOD','ODQ_CHANGEMODE','ODQ_ENTITYCNTR')
# l_output.append(l_record)


# # loop through dictionary to read each record and append it to output list l_output
# i = 0
# while i < length:
#     l_record = (init_json['d']['results'][i]['MANDT'], init_json['d']['results'][i]['ANLAGE'], init_json['d']['results'][i]['SPARTE'], init_json['d']['results'][i]['VSTELLE'], init_json['d']['results'][i]['ABLSPERR'], init_json['d']['results'][i]['BAPERTYP'], init_json['d']['results'][i]['ANSCHREI'], init_json['d']['results'][i]['SPEBENE'], init_json['d']['results'][i]['DRCKSTUF'], init_json['d']['results'][i]['ANLART'], init_json['d']['results'][i]['BEZUG'], init_json['d']['results'][i]['ABLESARTST'], init_json['d']['results'][i]['NODISCONCT'], init_json['d']['results'][i]['SERVICE'], init_json['d']['results'][i]['DEREGSTAT'], init_json['d']['results'][i]['INFOREL'], init_json['d']['results'][i]['ETIMEZONE'], init_json['d']['results'][i]['OUCONT'], init_json['d']['results'][i]['ERDAT'], init_json['d']['results'][i]['ERNAM'], init_json['d']['results'][i]['AEDAT'], init_json['d']['results'][i]['AENAM'], init_json['d']['results'][i]['BEGRU'], init_json['d']['results'][i]['LOEVM'], init_json['d']['results'][i]['UPDMOD'], init_json['d']['results'][i]['ODQ_CHANGEMODE'], init_json['d']['results'][i]['ODQ_ENTITYCNTR'])
#     l_output.append(l_record)
#     i += 1

# # Printing delta URL for reference  
# print(init_json['d']['__delta'])

# # Create a dynamic file name: result_YYYY_MM_DD_HH_MM_SS.csv
# file_name = 'result_' + str(datetime.now().strftime('%Y_%m_%d_%H_%M_%S')) + '.csv'

# # Copy data from output list l_output into data frame df_file and write to file 
# df_file = pd.DataFrame(l_output)
# df_file.to_csv(file_name, index = False, header = False)