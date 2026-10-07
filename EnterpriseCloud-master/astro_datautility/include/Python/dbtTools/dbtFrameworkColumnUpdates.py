from cProfile import run
import snowflake.connector
import pandas as pd
import datetime
from sqlalchemy import VARCHAR, false
import sys

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

def runDDL(conn,sql):
    connCur = conn.cursor()
    result = connCur.execute(sql).fetchone()
    connCur.close()
    return result

def buildDDL(db,schema,table,col,action,col_type = "varchar(128)"):
    if action == 'drop':
        sql = """EXECUTE IMMEDIATE $$
                    BEGIN
                        IF (EXISTS(SELECT *
                                    FROM INFORMATION_SCHEMA.COLUMNS
                                    WHERE TABLE_NAME = 'DEFECTIVE_PORTION_TYPES'
                                        AND TABLE_SCHEMA = '""" + schema + """'
                                        AND COLUMN_NAME = '""" + col + """')) THEN
                        ALTER TABLE """ + db + """.""" + schema + """.""" + table + """ DROP COLUMN """ + col + """;
                        RETURN 'COLUMN DROPPED';
                        END IF;
                        RETURN 'COLUMN NOT DROPPED';
                END;
                $$"""
    elif action == 'add':
        sql = """EXECUTE IMMEDIATE $$
                    BEGIN
                        IF (NOT EXISTS(SELECT *
                                    FROM INFORMATION_SCHEMA.COLUMNS
                                    WHERE TABLE_NAME = 'DEFECTIVE_PORTION_TYPES'
                                        AND TABLE_SCHEMA = '""" + schema + """'
                                        AND COLUMN_NAME = '""" + col + """')) THEN
                        ALTER TABLE """ + db + """.""" + schema + """.""" + table + """ ADD COLUMN """ + col + """ """ + col_type + """;
                        RETURN 'COLUMN ADDED';
                        END IF;
                        RETURN 'COLUMN NOT ADDED';
                    END;
                    $$"""
    #print(sql)
    return sql


def main(db,schema,user):

    ## local vars
    output = []

    bladebridgecols = []
    bladebridgecols.append('ERROR_FLAG')
    bladebridgecols.append('ERROR_REASON')
    bladebridgecols.append('ERROR_CODE')
    bladebridgecols.append('RECORD_INSERT_TIMESTAMP')
    bladebridgecols.append('OPERATION_TYPE')
    bladebridgecols.append('SRC_ROW_NUMBER')

    dbtcols = []
    dbtcols.append('AUDIT_LOG_ID')
    dbtcols.append('_ROW_HASH')

    try:
        conn = snowflake.connector.connect(user=user,
                                            account="telus-global.privatelink",
                                            client_session_keep_alive = False,
                                            warehouse= "developer_wh",
                                            database= db,
                                            role= "sysadmin_dev",
                                            schema= schema,
                                            threads= 1,
                                            authenticator="externalbrowser",
                                            autocommit=True)

        # get table list for schema
        sql = """select table_name from information_schema.tables
                                    where table_type = 'BASE TABLE'
                                    and table_schema = '""" + schema + """';"""
        df_tables = df(conn,sql)

        # if df_tables is empty, throw error
        if(df_tables.empty):
            message = "No Rows returned from informationschema.columns for this schema. Check spelling and case."
            raise sqlNoRowsError(schema,message)

        df_result = pd.DataFrame()
        for idx, row in df_tables.iterrows():
            table = row['TABLE_NAME']

            # remove bladebridge columns
            drop_result = []
            for col in bladebridgecols:
                action = 'drop'
                sql = buildDDL(db,schema,table,col,action)
                ddlresult =  runDDL(conn,sql)
                drop_result.append(table + "." + col + ": " + str(ddlresult))
            #print(drop_result)
            output.append(drop_result)

            # add dbt columns
            add_result = []
            for col in dbtcols:
                action = 'add'
                col_type = 'varchar(128)'
                sql = buildDDL(db,schema,table,col,action,col_type)
                ddlresult =  runDDL(conn,sql)
                add_result.append(table + "." + col + ": " + str(ddlresult))
            #print(add_result)
            output.append(add_result)

            # if df_tables is empty, throw error
            # if(df_tables.empty):
            #     message = "No Rows returned from informationschema.columns for this schema. Check spelling and case."
            #     raise sqlNoRowsError(schema,message)

        curDT = datetime.datetime.now()
        date_time = curDT.strftime("%m.%d.%Y.%H.%M.%S")
        fileout = db + "-" + schema + "-dbtFrameworkColumnUpdates - " + date_time + ".csv"
        output.to_csv(path_or_buf = fileout,index=False)

    except Exception as e:
        print(e)


if __name__ == "__main__":
    args = sys.argv[1:]
    db = args[0]
    schema = args[1]
    user = args[2]
    print("Arguments passed: DB: " + db + "  Schema: " + schema + "  user: " + user)
    main(
    ## set vars
    db,
    schema,
    user
    )