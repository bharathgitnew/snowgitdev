from audioop import add
from pickle import TRUE
import snowflake.connector
import pandas as pd
import datetime
from sqlalchemy import VARCHAR, false
import sys
import re
import os

## requires
# pip install snowflake-connector-python[pandas]
# pip install sqlalchemy
# command from dbtTools folder: python .\dbtModelTypeData.py ODS SIRFIS C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\sirfis eric.x.coleman@us.tel.com


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

def getFile(path):
    f = open(path,'r')
    filein = f.readlines()
    f.close()
    return filein

def writeFile(path,fileOut):
    f = open(path,'w')
    f.write(fileOut)
    f.close()

def getFileList(path):
    # get file list for path
    filesList = []
    for x in os.listdir(path):
        z = x.upper()
        if z.endswith('.SQL') and not z.startswith('V_'):
            filesList.append(path + "\\" + x)
    return filesList

def buildString(ddlstr,excludeStrings,addRowHash,addAudit):
    # ddlstr = ddlstr.splitlines()
    ddllist = re.split(r"\\n|\\t",ddlstr)
    sel = """,type_data as (
    SELECT
        """
    cnt = 1
    for col in ddllist:
        col = col.strip().upper()
        include = True
        if len(col) > 0:
            for excl in excludeStrings:
                if excl in col:
                    include = False
        else:
            include = False
        if include == True:
            col = col.strip(",")
            vals = col.split(" ")
            colname = vals[0]
            coltype = vals[1]
            val = "CAST(" + colname + " AS " + coltype.replace('DATE', 'TIMESTAMP_LTZ(9)') + ") AS " + colname + ","
            sel += val + """
        """
    sel = sel[:-10]
    if addAudit:
        sel += """,
        CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID"""
    if addRowHash:
        sel += """,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH"""
    sel += """
    FROM transform_data
)

"""
    return sel


def main(db,schema,path,user):

    ## local vars
    excludeStrings = []
    excludeStrings.append('CREATE OR REPLACE TABLE')
    excludeStrings.append(')COMMENT=')
    excludeStrings.append(';"')
    excludeStrings.append(";'")
    excludeStrings.append("_ROW_HASH")
    excludeStrings.append("AUDIT_LOG_ID")
    excludeStrings.append("PRIMARY KEY (")

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

        # path = 'C:\\Source\\Repos\\EnterpriseCloud\\dbt\\lz_to_ods\\models\\ariba'
        # get list of files
        filesList = getFileList(path)

        for file in filesList:
            # get file
            filein = getFile(file)

            # get last line in file
            lastLine = filein[-1].lower()

            # exit if conversion already done
            if "* from type_data" in lastLine:
                print("File already converted: " + file )
                continue

            # check if final select uses distinct
            if 'distinct' in lastLine:
                lastLine = "SELECT distinct * from type_data"
            else:
                lastLine = "SELECT * from type_data"
            filein.pop() # remove last line

            # get model attributes by searching lines
            addRowHash = False
            addAudit = False
            for line in filein:
                if re.search('alias=', line):
                    tableName = re.search('= *["\']([\w_]+)["\']', line).groups()[0]
                if '_ROW_HASH' in line.upper():
                    addRowHash = True
                if 'AUDIT_LOG_ID' in line.upper():
                    addAudit = True

            # get column list for schema.table
            sql = """select get_ddl('table','""" + schema + """.""" + tableName + """');"""
            ddlstr = getDDL(conn,sql)
            ddlstr = str(ddlstr)

            # if ddl is empty, throw error
            if(len(ddlstr)==0):
                message = "No ddl returned for schema.table: " + schema + "." + tableName
                raise sqlNoRowsError(schema,message)

            # build final string and overwrite model file
            sel = buildString(ddlstr,excludeStrings,addRowHash,addAudit)
            filestr = ''
            for line in filein:
                filestr += line
            fileOut = filestr + sel + lastLine
            writeFile(file,fileOut)
            print("File converted: " + file )

    except Exception as e:
        print(e)


if __name__ == "__main__":
    args = sys.argv[1:]
    db = args[0]
    schema = args[1]
    path = args[2]
    user = args[3]
    print("Arguments passed: DB: " + db + "  Schema: " + schema + " Path: " + path + " user: " + user)

    # set vars, call main
    main(db,schema,path,user )