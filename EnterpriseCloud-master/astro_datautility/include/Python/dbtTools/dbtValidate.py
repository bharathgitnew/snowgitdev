import snowflake.connector
import pandas as pd
import datetime
from sqlalchemy import false
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

def main(sourcedb,targetdb,schema,user,filter='noval'):
    try:
        conn = snowflake.connector.connect(user=user,
                                            account="telus-global.privatelink",
                                            client_session_keep_alive = False,
                                            warehouse="developer_wh",
                                            database=sourcedb,
                                            role= "sysadmin_dev",
                                            schema= schema,
                                            threads= 1,
                                            authenticator="externalbrowser",
                                            autocommit=True)

        if filter =='noval':
            sql = """select table_name from information_schema.tables
                                        where table_type = 'BASE TABLE'
                                        and table_schema = '""" + schema + """';"""
        else:
            sql = """select table_name from information_schema.tables
                                        where table_type = 'BASE TABLE'
                                        and table_schema = '""" + schema + """'
                                        and upper(table_name) like '""" + filter + """%';"""
        df_tables = df(conn,sql)

        # if df_tables is empty, throw error
        if(df_tables.empty):
            message = "No Rows returned from informationschema.columns for this schema. Check spelling and case."
            raise sqlNoRowsError(schema,message)

        df_result = pd.DataFrame()
        for idx, row in df_tables.iterrows():
            table = row['TABLE_NAME']
            sql_rows = """select column_name from """ + targetdb + """.information_schema.columns
                                            where 1=1
                                            and table_catalog = '""" + targetdb + """'
                                            and table_schema = '""" + schema + """'
                                            and table_name = '""" + table + """'
                                            and column_name not in('ERROR_FLAG',
                                                                    'ERROR_REASON',
                                                                    'ERROR_CODE',
                                                                    'RECORD_INSERT_TIMESTAMP',
                                                                    'OPERATION_TYPE',
                                                                    'SRC_ROW_NUMBER',
                                                                    'AUDIT_LOG_ID',
                                                                    '_ROW_HASH'
                                                                        )"""
            df_col = df(conn,sql_rows)

            # if df_col is empty, throw error with table name
            if(df_col.empty):
                message = "No Rows returned from informationschema.columns for this table"
                raise sqlNoRowsError(table,message)

            # build hash
            hashstr = "hash("
            for col_idx, col in df_col.iterrows():
                column = df_col.iloc[col_idx]['COLUMN_NAME']
                hashstr += column + ','

            hashstr = hashstr[:-1]
            hashstr += ")"

            # execute the check query for the table
            sql = """select
                    '""" + table + """' as tableName,
                    (select count(*) from """ + sourcedb + """.""" + schema + """.""" + table + """) as srccnt,
                    (select count(*) from """ + targetdb + """.""" + schema + """.""" + table + """) as dbtcnt,
                    (select coalesce(sum(h),0) from (select """ + hashstr + """ as h from """ + sourcedb + """.""" + schema + """.""" + table + """)) as srchash,
                    (select coalesce(sum(h),0) from (select """ + hashstr + """ as h from """ + targetdb + """.""" + schema + """.""" + table + """)) as dbthash"""
            df_row = df(conn,sql)
            df_row['CNTCHK'] = (df_row['SRCCNT'] - df_row['DBTCNT'])
            df_row['HASHCHK'] = (df_row['SRCHASH'] - df_row['DBTHASH'])
            df_result = pd.concat([df_result,df_row],ignore_index=True)
            #print(df_result)



        fileout = targetdb + "-" + schema + "-dbtValidate.csv"
        df_result.to_csv(path_or_buf = fileout,index=False)

    except Exception as e:
        print(e)


if __name__ == "__main__":
    args = sys.argv[1:]

    sourcedb = args[0]
    targetdb = args[1]
    schema = args[2]
    user = args[3]
    try:
        filter = args[4]
    except:
        filter = 'noval'
    print("""Arguments passed: SourceDB: """ + sourcedb +
            """  TargetDB: """ + targetdb +
            """  Schema: """ + schema +
            """  user: """ + user +
            """  filter: """ + filter
            )
    main(
    ## set vars
    sourcedb,
    targetdb,
    schema,
    user,
    filter
    )