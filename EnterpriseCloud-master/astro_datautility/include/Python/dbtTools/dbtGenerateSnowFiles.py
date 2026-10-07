from audioop import add
from fileinput import filename
from pickle import TRUE
import snowflake.connector
import pandas as pd
import datetime
from sqlalchemy import VARCHAR, false, table
import sys
import re
import os

## requires
# pip install snowflake-connector-python[pandas]
# pip install sqlalchemy


class sqlNoRowsError(Exception):
    """Exception raised for now rows."""

    def __init__(self, objectName, message):
        self.objectName = objectName
        self.message = message
        super().__init__(self.message)

    def __str__(self):
        return f'Error: {self.objectName} - {self.message}'

def df(conn,sql):
    connCur = conn.cursor()
    connCur.execute(sql)
    df = pd.DataFrame(connCur.fetch_pandas_all())
    connCur.close()
    return df

def getDDL(conn,sql):
    connCur = conn.cursor()
    result = connCur.execute(sql).fetchone()
    connCur.close()
    return result

def writeFile(path,fileOut):
    f = open(path,'w')
    f.write(fileOut)
    f.close()


def main(db,schema,kcard,user):

    ## local vars
    excludeStrings = []
    excludeStrings.append('CREATE OR REPLACE TABLE')
    excludeStrings.append(')COMMENT=')
    excludeStrings.append(';"')
    excludeStrings.append(";'")
    excludeStrings.append("PRIMARY KEY (")
    excludeStrings.append('ERROR_FLAG')
    excludeStrings.append('ERROR_REASON')
    excludeStrings.append('ERROR_CODE')
    excludeStrings.append('RECORD_INSERT_TIMESTAMP')
    excludeStrings.append('OPERATION_TYPE')
    excludeStrings.append('SRC_ROW_NUMBER')
    excludeStrings.append('AUDIT_LOG_ID')
    excludeStrings.append('_ROW_HASH')

    try:
        # create snowflake connection string
        conn = snowflake.connector.connect(user=user,
                                            account="telus-global.privatelink",
                                            client_session_keep_alive = False,
                                            warehouse= "developer_wh",
                                            database= db+"_dev",
                                            role= "sysadmin_dev",
                                            schema= schema,
                                            threads= 1,
                                            authenticator="externalbrowser",
                                            autocommit=True)


        sql = """select table_name from information_schema.tables
                                    where table_type = 'BASE TABLE'
                                    and table_schema = '""" + schema + """';"""
        df_tables = df(conn,sql)

        # if df_tables is empty, throw error
        if(df_tables.empty):
            message = "No Rows returned from informationschema.columns for this schema. Check spelling and case."
            raise sqlNoRowsError(schema,message)

        # for each table, build view model
        df_result = pd.DataFrame()
        current_files = os.listdir('C:\Sources\Repos\EnterpriseCloud\Snow')
        used_kcards = [int(re.search('K\.'+kcard+'\.(\d+)__.*?\.sql', file).groups()[0]) for file in current_files if re.match('K\.'+kcard+'\.(\d+)__.*?\.sql', file)]
        next_num = str(max(used_kcards)+1) if used_kcards else '1'
        snowpath = 'C:\\Sources\\Repos\\EnterpriseCloud\\Snow\\K.'+kcard+'.'+next_num+'__'+'create_'+db+'_'+schema+'_tables.sql'

        snowtxt = 'USE DATABASE <<'+db+'>>;\nUSE SCHEMA '+schema+';\n'

        for idx, row in df_tables.iterrows():
            tableName = row['TABLE_NAME']

            # get column list for schema.table
            sql = """select get_ddl('table','""" + schema + """.""" + tableName + """');"""
            ddlstr = getDDL(conn,sql)
            ddlstr = str(ddlstr).replace('\\t','')

            # if ddl is empty, throw error
            if(len(ddlstr)==0):
                message = "No ddl returned for schema.table: " + schema + "." + tableName
                raise sqlNoRowsError(schema,message)

            snowtxt += '\ncreate or replace table '+tableName+'('

            match = re.search("create or replace TABLE "+tableName+" \(\\\\n(.*?)\\\\n\)", ddlstr)
            ddls = match.groups()[0].split('\\n')
            snowtxt += '\n\t'+'\n\t'.join(ddls)+'\n);\n'

        writeFile(snowpath, snowtxt)
        print('Created Snow file:', snowpath)

    except Exception as e:
        print(e)


if __name__ == "__main__":
    args = sys.argv[1:]
    db = args[0]
    schema = args[1]
    kcard = args[2]
    user = args[3]
    print("Arguments passed: DB: " + db + "  Schema: " + schema + " Kanbanize ID: " + kcard + " user: " + user)

    # set vars, call main
    main(db,schema,kcard,user)