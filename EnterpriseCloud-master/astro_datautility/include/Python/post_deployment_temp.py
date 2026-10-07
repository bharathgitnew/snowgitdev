from include.Python.TELTools import getSnowFlakeConn
import os
import json

def latest_default_run_update(LZ_SCHEMA,last_default_run_file):
    
    CURRENT_TIMESTAMP = '1990-01-01_00_00_00_000000'
    messages = []
    LZ_DB = os.environ["SNOWFLAKE_LZ"]
    #last_default_run_file= r"\\telusdwappprod\Shares\Files\TokyoElectron\Python\RuntimeConfig\crm_file\crm.LastDefaultRun.json"


    with open(last_default_run_file,'r',encoding='utf-8-sig') as rn:
        last_date = json.load(rn)
        LastDefaultRun = last_date['LastDefaultRun']

    conn, messages = getSnowFlakeConn(LZ_DB, LZ_SCHEMA, messages)
    cur = conn.cursor()
    
    check_sql = 'select count(*) from CONTROLTABLE'
    result = cur.execute(check_sql)
    count = result.fetchall()
    
    if not count[0][0]:
        insert_sql = f"""insert into CONTROLTABLE(
        RUN_TIME, 
        INCREMENTAL_START_VALUE, 
        INCREMENTAL_END_VALUE, 
        EXTRACTION_START_TIME, 
        EXTRACTION_end_TIME, 
        TABLE_NAME, 
        MAX_FILE_DATE, 
        ROW_COUNT
        ) 
        values 
        (
            '{CURRENT_TIMESTAMP}', 
            '', 
            '{LastDefaultRun}', 
            '', 
            '', 
            'LastDefaultRun',
            '',
            '');"""
        result = cur.execute(insert_sql)

        conn.close()