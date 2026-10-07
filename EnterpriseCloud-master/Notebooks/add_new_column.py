import snowflake.connector
import json

#globals
database= 'ODS'
schema = 'SAPAPI'
filename = 'test_table.sql'

def get_table_columns(table_name):
    user='pritesh.x.gandhi@us.tel.com'
    columns = []
    try:

        with snowflake.connector.connect(
            user=user,
            account="telus-global.privatelink",
            client_session_keep_alive = False,
            warehouse= "developer_wh",
            database= database,
            role= "sysadmin_dev",
            schema= schema,
            threads= 1,
            authenticator="externalbrowser",
            autocommit=True
        ) as connection:
            with connection.cursor() as cursor:
                query = f"desc table {table_name}"
                print(query)
                cursor.execute(query)
                columns_info = cursor.fetchall()
                single_columns = []
                colunn_dtypes = []
                print(columns_info)
                for column_info in columns_info:
                    column_name = column_info[0]
                    data_type = column_info[1]
                    # #temp_json = json.loads(data_type)
                    # print(temp_json)
                    # if temp_json['type'] == 'TEXT':
                    #     dtype = temp_json['type'] +'('+str(temp_json['length'])+')'
                    # elif temp_json['type'] == 'TIMESTAMP_NTZ':
                    #     dtype = temp_json['type'] +'('+str(temp_json['scale'])+')'
                    # else:
                    #     dtype = temp_json['type']
                    single_columns.append(column_name)
                    colunn_dtypes.append(column_name + ' ' + data_type)
    except Exception as e:
        print(f"Error fetching columns for {table_name}: {e}")
    return single_columns,colunn_dtypes

def generate_alter_table_sql(db,schema,table_name, columns_dtype,
                             single_columns_new,select_new_as_null):
    """
    Generates SQL script to add a new column to the table.
    """
    return f"""
USE DATABASE <<{db}>>;
USE SCHEMA {schema};

create or replace table {table_name}_BACKUP CLONE {table_name};

create or replace TABLE {table_name} (
	{columns_dtype}
)COMMENT='Table for {table_name} file.'
;

insert into {table_name}(
		{single_columns_new})
select
		{select_new_as_null}
from {table_name}_BACKUP;

drop table if exists {table_name}_BACKUP;"""


def main(table_name,new_column_list,position_column,database,schema,filename):

    single_columns,columns_dtype = get_table_columns(table_name)
    select_new_as_null = single_columns.copy()


    for i in range(len(single_columns)):
        if single_columns[i].lower() == position_column.lower():
            single_columns[i+1:i+1] = new_column_list

    for i in range(len(select_new_as_null)):
        if select_new_as_null[i].lower() == position_column.lower():
            new_column_list_nulls = [f'NULL AS {x}' for x in new_column_list ]
            select_new_as_null[i+1:i+1] = new_column_list_nulls

    for j in range(len(columns_dtype)):
        if position_column.lower() in columns_dtype[j].lower():
            new_column_list_dtype = [f'{x} VARCHAR' for x in new_column_list ]
            columns_dtype[j+1:j+1] = new_column_list_dtype
    # print(id(select_new_as_null) , id(single_columns))
    columns_dtype_str = ',\n\t'.join(columns_dtype)
    single_columns_str = ',\n\t'.join(single_columns)
    select_new_as_null_str = ',\n\t'.join(select_new_as_null)

    db=database
    schema = schema
    sql_file = generate_alter_table_sql(db,schema,table_name, columns_dtype_str ,single_columns_str,select_new_as_null_str)    # for table_name, new_column in table_column_mapping.items():

    file_path = filename

    with open(file_path, 'a') as file:
        file.write(sql_file)

if __name__ == "__main__":

    main('ZCDV_T_CMTU011_VBEP_HIST',['UPDATE_TIME','IS_DELETED'],'UPDATE_DATE',database,schema,filename)
