#imports
import TELTools as TT
import json
#global 
SAP_JSON_CONFIG_PATH = 'F:\Shares\Configuration\TelTools_Sapapi_Finance.json'

#set inputs
db='LZ_DEV'
schema= 'SAPAPI'
run_time_name = '2024-02-20_06_08_10_361857'

with open(SAP_JSON_CONFIG_PATH,'r') as j:
    config = json.load(j)

active_cds = []
for key,val in config.items():
    if val.get('active') == 'true' :
        active_cds.append(key)

messages = []
conn,messages = TT.getSnowFlakeConn(db,schema,messages)

if conn != 'no connection': 
    cur = conn.cursor()
    query = f"SELECT TABLE_NAME FROM CONTROLTABLE WHERE RUN_TIME = '{run_time_name}'"
    cur.execute(query)
    columns = cur.fetchall()
    columns = [col[0] for col in columns]
    failed_cds = [cds for cds in active_cds if cds not in columns ]
    print(','.join(failed_cds))
else:
    print("connection failed")