
from getSPOList import get_access_token,get_teltools_config,load_config
import TELTools as TT
import requests

#This script will generate the json config entry for TelTool_Sharepoint.json for a given List

#Input
site_name = 'TMEA-Environmental-KPI'
list_name = 'TMEAEnvironmentalKPI'
sf_table = 'TMEAENVIRONMENTALKPI'
sf_schema = 'SHAREPOINT'

#Required methods
tenant_id,client_id,client_secret,list_config_path,api_url,oauth_url = get_teltools_config()
config = load_config(list_config_path)
client_secret = TT.getAzureSecret(client_secret).value
#get token
access_token = get_access_token(client_id, client_secret, tenant_id,oauth_url)

#get the site id:
get_site_id_url = f"https://graph.microsoft.com/v1.0/sites/root:/sites/{site_name}"
headers = {'Authorization': f'Bearer {access_token}'}
response = requests.request("GET", get_site_id_url, headers=headers)
if response.status_code == 200:
    json_data = response.json()
    ids = json_data['id']
    site_id = ids.split(',')[1]
else:
    print(f"API failed for get site id {response}")
#get_lookup_id
get_lookup_fields="https://graph.microsoft.com/v1.0/sites/<<site_id>>/lists/<<list_name>>/items?$top=5000&expand=fields"
get_lookup_fields = get_lookup_fields.replace('<<site_id>>',site_id).replace('<<list_name>>',list_name)
response1 = requests.request("GET", get_lookup_fields, headers=headers)
if response1.status_code == 200:
    json_data = response1.json()
    json_list = json_data["value"]
    list_fields = [i['fields'] for i in json_list]
    max_list_field = max(list_fields, key=lambda x: len(x))
    lookup_fields = [items.upper() for items in max_list_field if 'LookupId' in items ]
    lookup_fields = [items.replace('LOOKUPID','') for items in lookup_fields ]
    lookup_fields_str = ','.join(lookup_fields)
else:
    print(f"API failed for get look up id {response1}")

#get the final teltools_sharepoint.json config entry
print(f'''\n\n\n\n\n"{sf_table}":{{
    "site_id": "{site_id}",
    "site_name":"{site_name}",
    "list_name": "{list_name}",
    "snowflake_schema":"{sf_schema}",
    "snowflake_table":"{sf_table}",
    "lookup_fields":"{lookup_fields_str}"
}}''')