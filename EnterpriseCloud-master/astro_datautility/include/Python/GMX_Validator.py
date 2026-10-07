from operator import concat
import snowflake.connector
from smtplib import SMTP
import smtplib
from IPython.display import display,HTML
import numpy as np
import json
import pandas as pd
from tabulate import tabulate
from email.message import EmailMessage
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from pretty_html_table import build_table
import os
from snowflake.connector.pandas_tools import write_pandas
from datetime import datetime
from datetime import timedelta
msg = EmailMessage()
username=os.getenv("SNOWFLAKE_USER")
password=os.getenv("SNOWFLAKE_SECRET")
Database=os.getenv("SNOWFLAKE_LZ")
conn = snowflake.connector.connect(
user=username,
password=password,
account="telus-global.privatelink",
warehouse="DEVELOPER_WH"
)
master_sql='select DatabaseName,SAPSchemaName,GMXSchemaName,SAPAPI_TableName,SAPH_TableName,DateField,Primary_Key from '+Database+'.SAPAPI.GMX_Validator_Config'
master_cursor=conn.cursor()
master_cursor.execute(master_sql)
master_results=master_cursor.fetchall()
df = pd.DataFrame(
columns = ['SAPH_Table','SAPAPI_Table', 'SAPAPI_Date','SAPH_Date','SAPAPI_Record_Count','SAPH_Record_Count','Difference','Status'])
df_missingkeys = pd.DataFrame(
columns = ['Date','Table Having Extra Keys','Key Field Name','List of Keys'])
i=0
missing_keys_data=[]
for row in master_results:
    if row[0]=='LZ':
        dbname=os.getenv("SNOWFLAKE_LZ")
    if row[0]=='ODS':
        dbname=os.getenv("SNOWFLAKE_ODS")
    if row[0]=='COMMON':
        dbname=os.getenv("SNOWFLAKE_COMMON")
    SAPSchemaName=row[1]
    GMXSchemaName=row[2]
    SAPAPI_TableName=row[3]
    SAPH_TableName=row[4]
    DateField=row[5]
    primary_key=''
    splits=row[6].split("+")
    for split in splits:
        primary_key=primary_key+","+split
    primary_key=primary_key.replace(",","",1)
    date_comp_sql='select \''+row[3]+'\' as SAPAPI_Table,\''+row[4]+'\' as SAPH_Table, SAPAPI_Date,SAPH_Date,SAPAPI_Record_Count,SAPH_Record_Count,(SAPAPI_Record_Count-SAPH_Record_Count) as Difference,(case when Difference=0 then \'Matched\' else \'UnMatched\' end) as Status from (select '+row[5]+' as SAPAPI_Date,count(*) as SAPAPI_Record_Count from '+dbname+'.'+SAPSchemaName+'.'+row[3]+' group by '+row[5]+' order by '+row[5]+' desc) as SAPAPI full outer join (select TO_CHAR('+row[5]+',\'YYYYMMDD\') as SAPH_Date,count(*) as SAPH_Record_Count from '+dbname+'.'+GMXSchemaName+'.'+row[4]+' group by '+row[5]+' order by TO_CHAR('+row[5]+',\'YYYYMMDD\') desc) as SAPH on SAPAPI_Date=SAPH_Date order by SAPAPI_Date desc'
    date_comp_cursor=conn.cursor()
    date_comp_cursor.execute(date_comp_sql)
    date_comp_results=date_comp_cursor.fetchall()
    for rows in date_comp_results:
        if rows[7]=='UnMatched':
            df.loc[i]=[rows[0],rows[1],rows[2],rows[3],rows[4],rows[5],rows[6],rows[7]]
            if rows[6] is not None:
                if int(rows[6])>0:
                    missing_keys_sql='select listagg(Primary_Key,\';\') as Primary_Key from (select concat('+primary_key+')as Primary_Key from ODS.SAPAPI.'+rows[0]+' where '+DateField+'=\''+rows[2]+'\' EXCEPT select concat('+primary_key+') as Primary_Key from ODS.SAPH.'+rows[1]+' where TO_CHAR('+DateField+',\'YYYYMMDD\')=\''+rows[3]+'\')'
                    missing_keys_cursor=conn.cursor()
                    missing_keys_cursor.execute(missing_keys_sql)
                    missing_keys_results=missing_keys_cursor.fetchall()
                    list1=[rows[0],rows[1],rows[2],missing_keys_results,'GMX Table is missing these keys']
                    missing_keys_data.append(list1)
                else:
                    missing_keys_sql='select listagg(Primary_Key,\';\') as Primary_Key from (select concat('+primary_key+')as Primary_Key from ODS.SAPH.'+rows[1]+' where TO_CHAR('+DateField+',\'YYYYMMDD\')=\''+rows[3]+'\') EXCEPT select concat('+primary_key+') as Primary_Key from ODS.SAPAPI.'+rows[0]+' where '+DateField+'=\''+rows[3]+'\''
                    missing_keys_cursor=conn.cursor()
                    missing_keys_cursor.execute(missing_keys_sql)
                    missing_keys_results=missing_keys_cursor.fetchall()
                    list1=[rows[0],rows[1],rows[2],missing_keys_results,'API Table is missing these keys']
                    missing_keys_data.append(list1)
            i=i+1
df = df.replace(to_replace='None', value=np.nan).dropna()
json_object = json.dumps(missing_keys_data, indent=5)

# Writing to sample.json
current_date=datetime.today()
with open("F:\Shares\Files\GMX_Validator\GMX_Validations_"+datetime.strftime(current_date,"%Y-%m-%dT%H%M%S")+".json", "w") as outfile:
    outfile.write(json_object)
df.to_csv('test_file.csv', index=False)
date_comp_cursor.close()
msg=df
html = """\
<html>
  <head></head>
  <body>
    {0}
  </body>
</html>
""".format(df.to_html())
msg = MIMEMultipart()
msg=MIMEText(html, 'html')
msg['To'] = "farooque.x.shaikh@us.tel.com;eric.x.coleman@us.tel.com;kathryn.turman@us.tel.com;jesus.x.garcia@us.tel.com;varun.x.tiwari@us.tel.com;jay.spiers@us.tel.com"
msg['Subject'] = "GMX Validation Phase Validation Report"
msg['From'] = 'farooque.x.shaikh@us.tel.com'
server = smtplib.SMTP('smtp.us.tel.com','25')
server.sendmail(msg['From'], msg['To'] , msg.as_string())
server.quit()
os.remove('test_file.csv')