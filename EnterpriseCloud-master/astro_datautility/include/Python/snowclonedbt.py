import argparse
import json
import os
import re
from include.Python.snowflake_intricity import Connection
import sys

def snowclone(snowflake_account, snowflake_region, snowflake_user, snowflake_secret, snowflake_role, snowflake_database, snowflake_schema, snowflake_warehouse, env, build_number, config_database, clone_sql, config_dbt):
    print('Env: ' + env)
    print('Build Number: ' + build_number)

    try:
        # Get config file
        with open(config_database) as json_file:
            config = json.load(json_file)
        with open(config_dbt) as json_file:
            dbt_dict = json.load(json_file)
    except:
        e = sys.exc_info()[0]
        msg = sys.exc_info()[1]
        print('Get Config File', e, msg)
        sys.exit(1)

    try:
        # Get SQL File
        with open(clone_sql) as sql_file:
            sql_content = sql_file.read()
    except:
        e = sys.exc_info()[0]
        msg = sys.exc_info()[1]
        print('Get SQL File', e, msg)
        sys.exit(1)

    # Replace <<env>> and <<build_number>>
    sql_content = re.sub(r'\<\<env\>\>', env, sql_content)
    sql_content = re.sub(r'\<\<build_number\>\>', build_number, sql_content)
    sql_content = re.sub(r'\<\<sysadmin\>\>', dbt_dict[env]['SYSADMIN'], sql_content)

    # Connect to snowflake db
    conn = Connection(snowflake_account+'.'+snowflake_region, snowflake_user, snowflake_secret, snowflake_database, snowflake_schema, snowflake_warehouse, snowflake_role)

    # Replace <<type>>
    for key in config[env]:
        # Replace <<type>>
        key = config[env].get(key)
        sql = re.sub(r'\<\<type\>\>', key, sql_content)

        # Create temp sql file
        sql_file_name = 'clone_{0}_{1}_{2}.sql'.format(key, env, build_number)
        with open(sql_file_name, 'w') as sql_file:
            sql_file.write(sql)
            sql_file.close()
            print(sql)

        # Execute sql from temp file
        conn.execute_sqlfile(sql_file_name)

        # Remove file
        # os.remove(sql_file_name)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-a', '--snowflake-account', type = str, help = 'The name of the snowflake account (e.g. ly12345)', required = True)
    parser.add_argument('-sr','--snowflake-region', type = str, help = 'The name of the snowflake region (e.g. ap-southeast-2)', required = True)
    parser.add_argument('-u', '--snowflake-user', type = str, help = 'The name of the snowflake user (e.g. DEPLOYER)', required = True)
    parser.add_argument('-p', '--snowflake-secret', type = str, help = 'The password of the snowflake user (e.g. P@$$W0rd!)', required = True)
    parser.add_argument('-r', '--snowflake-role', type = str, help = 'The name of the role to use (e.g. DEPLOYER_ROLE)', required = True)
    parser.add_argument('-d', '--snowflake-database', type = str, help = 'The name of the database to use (e.g. LZ_DEV)', required = True)
    parser.add_argument('-s', '--snowflake-schema', type = str, help = 'The name of the schema to use (e.g. CONTROL)', required = True)
    parser.add_argument('-w', '--snowflake-warehouse', type = str, help = 'The name of the warehouse to use (e.g. DEPLOYER_WAREHOUSE)', required = True)
    parser.add_argument("-e", "--env", help="Environment to be used", type=str)
    parser.add_argument("-b", "--build-number", help="Build Number to be used", type=str)
    parser.add_argument('-cd', '--config-database', type = str, help = 'The JSON file for the configuration of the database environment (e.g. Config\database.json)')
    parser.add_argument('-cs', '--clone-sql', type = str, help = 'The SQL file for cloning of the database environment and change history table(e.g. clone.sql)')
    parser.add_argument('-cdbt', '--config-dbt', type = str, help = 'The JSON file for the configuration of the dbt environment (e.g. Config\dbt.json)')
    args = parser.parse_args()

    snowclone(args.snowflake_account, args.snowflake_region, args.snowflake_user, args.snowflake_secret, args.snowflake_role, args.snowflake_database, args.snowflake_schema, args.snowflake_warehouse, args.env, args.build_number, args.config_database, args.clone_sql, args.config_dbt)
