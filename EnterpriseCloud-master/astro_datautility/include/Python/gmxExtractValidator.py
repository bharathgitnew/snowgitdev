import pandas as pd
from include.Python.TELTools import getSnowFlakeConn,sendEmail
import os
import sys
import json
import re


# SQL Query to retrieve data
LZ_DB = os.environ["SNOWFLAKE_LZ"]
ODS_DB = os.environ["SNOWFLAKE_ODS"]
SCHEMA = "SAPH"
ENV = os.environ['SNOWFLAKE_ENV']



def getFileUploaderConfig(uploader_config):
    with open(uploader_config,'r') as f:
        file_uploader_json = json.load(f,strict=False)
    return file_uploader_json

def connectSnowflake(db, schema):   
    try:
        conn, messages = getSnowFlakeConn(db, schema, [])
        if conn == 'no connection':
            print("Failed to establish a Snowflake connection.")
            return None, messages
        return conn, messages
    except Exception as e:
        print(f"Error establishing Snowflake connection: {e}")
        return None, str(e)

def executeSQL(conn, SQL_QUERY):
    try:
        with conn.cursor() as cur:
            result = cur.execute(SQL_QUERY).fetchall()
        return result,"Success"
    except Exception as e:
        print(f"Error executing SQL query: {e}")
        return [],str(e)

def validateData(result,exclude_from_validation,runType): 
    columns = ['gmx_count', 'gmx_table', 'gmx_date', 'sf_count', 'sf_date', 'sf_table']
    df = pd.DataFrame(result, columns=columns)
    
    df["sf_count"] = df["sf_count"].fillna(0).astype(int) 
    df["gmx_count"] = df["gmx_count"].fillna(0).astype(int)
    
    mismatch_df = df[df["gmx_count"] != df["sf_count"]]
    mismatch_df = mismatch_df[~mismatch_df['gmx_table'].isin(exclude_from_validation)]

    if len(mismatch_df) > 0:
        df_result = mismatch_df[['gmx_table', 'gmx_count']]
        html_table = mismatch_df[['gmx_table', 'gmx_count','gmx_date']].to_html(index=False, border=1, justify="center")
        final_result_map = {row['gmx_table']: row['gmx_count'] for _, row in df_result.iterrows()}
        print(f"Unsuccessful processing: {final_result_map}")
        
        if ENV.upper() == "PROD":
            email_body = f"""
                <html>
                <body>
                    <p>Hi Team,</p>
                    <p>The following GMX files failed to process in Snowflake.</p>
                    {html_table}
                    <p>Please investigate the issue.</p>
                    <p>Thanks,<br>BI-Prod-Support<br></p>
                </body>
                </html>
                """
            print("sending email")
            sendEmail(
                        'BI.Production-Alert-no-reply@us.tel.com',
                        subject = f'GMX (runType: {runType}) Files Processing Issue.',
                        email_content = email_body
                    )
        raise Exception(f"Unsuccessful processing: {final_result_map}")
    
    print("Data validation successful: All counts and tables match.")

def main(runType):
    
    config_type = "FileUploader_GMX_ONDEMAND" if runType.upper() == "ON_DEMAND" else "FileUploader_GMX"
    #exclude_from_validation = ["SAP_US_SDT_EV_LIPSSF", "SAP_US_SDT_EV_VBAKEX","SAP_US_SDT_EV_LIPS","SAP_US_SDT_EV_VBAK","SAP_US_FIT_EV_BKPFN"] if runType.upper() == "ON_DEMAND" else []
    exclude_from_validation = []
    uploader_config = f'/usr/local/airflow/include/Configuration/{config_type}.json'
    file_uploader_json=getFileUploaderConfig(uploader_config)
    selection_list = [re.sub(r'^SF_|_GMX$', '', val["SNOWFLAKE_TABLE_NAME"]) for val in file_uploader_json.values()]
    selection_str = ", ".join(f"'{name}'" for name in selection_list)
    
    runTypeFolders = {
        "DAILY": ["US/", "Common/"],
        "ON_DEMAND": ["USOndemand/"]
    }
    folderList = runTypeFolders.get(runType)
    folderList_str = ", ".join(f"'{name}'" for name in folderList)
    
    SQL_QUERY = f"""
    with controltable as 
    (
        select sum(row_count) as row_count, table_name, run_time 
        from {LZ_DB}.{SCHEMA}.controltable 
        where max_file_date in ({folderList_str})
        group by 2, 3
    ),
    controltable_latest as 
    (
        select row_count, run_time, UPPER(REGEXP_REPLACE(table_name,'_GMX$','')) as table_name
        from controltable 
        qualify(row_number() over(partition by table_name order by run_time desc))=1
    ),
    filelist as
    (
        select jsonfield:RecordCount as recordcount , 
        UPPER(REGEXP_REPLACE(jsonfield:TableOrViewName,'^SF_|_GMX$','')) as tableorviewname,
         _filedate
        from {LZ_DB}.{SCHEMA}.filelist   
    ),
    filelist_latest as 
    (
        select recordcount, tableorviewname, _filedate
        from filelist
        where tableorviewname in ({selection_str})
        qualify(row_number() over (partition by tableorviewname order by _filedate desc)) = 1
    ) 
    select 
        recordcount as gmx_count,
        tableorviewname as gmx_table,
        _filedate as gmx_date,
        row_count as sf_count,
        run_time as sf_date,
        table_name as sf_table
    from filelist_latest 
    left join controltable_latest 
    on tableorviewname = table_name 
    and to_char(_filedate) = run_time
    """
    print(SQL_QUERY)
    
    conn, conn_messages = connectSnowflake(LZ_DB, SCHEMA)
    if conn is None:
        raise Exception(f"Failed while connecting to Snowflake: {conn_messages}")
    try:
        #print(SQL_QUERY)
        result,result_messages = executeSQL(conn, SQL_QUERY)
        if not result:
            raise Exception(f"Failed while Querying to Snowflake: {result_messages}")
        
        validateData(result,exclude_from_validation,runType)
    finally:
        conn.close()

if __name__ == "__main__":
    args = sys.argv[1:]
    runType = args[0].upper()
    main(runType)
