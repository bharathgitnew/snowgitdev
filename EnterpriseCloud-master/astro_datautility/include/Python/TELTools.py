import os
import sys
from azure.identity import CertificateCredential
from azure.keyvault.secrets import SecretClient
import pandas as pd
import snowflake.connector as sc
from snowflake.connector.pandas_tools import write_pandas
from snowflake.connector.errors import OperationalError
import time
from datetime import datetime
import json
import glob
import sqlalchemy
from subprocess import Popen, PIPE
import warnings
import gzip
from azure.storage.blob import ContainerClient
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
import ast
from pyatlan.client.atlan import AtlanClient
from pyatlan.model.enums import LineageDirection, DataProductVisibility, CertificateStatus
from pyatlan.model.assets import Asset, Schema, Table, Column, View, DataProduct
from pyatlan.model.lineage import FluentLineage
from pyatlan.model.fluent_search import FluentSearch, CompoundQuery
import logging
import typing
import numpy as np
import re
import io
from pydantic.v1.main import ModelMetaclass
from typing import IO,Tuple,Optional,List 

#------------------------------------------------------------------------------------#

# Noticed some noisy warnings in Astronomer. The following code suppresses them:

logging.getLogger("snowflake.connector.ocsp_snowflake").setLevel(logging.CRITICAL)
logging.getLogger("snowflake.connector.pandas_tools").setLevel(logging.CRITICAL)

warnings.filterwarnings(
    "ignore",
    message=".*pandas only supports SQLAlchemy connectable.*",
    category=UserWarning
)

warnings.filterwarnings(
    "ignore",
    message=".*is_datetime64tz_dtype is deprecated.*",
    category=FutureWarning
)

#------------------------------------------------------------------------------------#

PUT_SNOWFLAKE_MAX_RETRIES = 3
PUT_SNOWFLAKE_RETRY_WAIT_SECONDS = 5
Attachment = Tuple[str, bytes]  # (filename, raw bytes)

db_mapping = {
    'ADMIN_DEV': 'ADMIN',
    'ADMIN_SIT': 'ADMIN',
    'ADMIN_QA': 'ADMIN',
    'ADMIN_BUILD': 'ADMIN',
    'LZ_DEV': 'LZ_PROD',
    'LZ_SIT': 'LZ_PROD',
    'LZ_QA': 'LZ_PROD',
    'LZ_BUILD': 'LZ_PROD',
    'ODS_DEV': 'ODS',
    'ODS_SIT': 'ODS',
    'ODS_QA': 'ODS',
    'ODS_BUILD': 'ODS',
    'COMMON_DEV': 'COMMON',
    'COMMON_SIT': 'COMMON',
    'COMMON_QA': 'COMMON',
    'COMMON_BUILD': 'COMMON',
    'PUB_DEV': 'PUB',
    'PUB_SIT': 'PUB',
    'PUB_QA': 'PUB',
    'PUB_BUILD': 'PUB',
}

# Azure Key vault
def getAzureCred():

    #load env variable pointing to DEV or PROD keyvault
    azureKeyVault = os.getenv("AZURE_KEY_VAULT")
    azureClientSecret = os.getenv("AZURE_CLIENT_SECRET")
    if not bool(azureKeyVault):
        print("Azure Key vault environment variable failed to load.")
        raise Exception("AZURE_KEY_VAULT environment variable failed to load")

    # Certifiate path with Service principal values
    
    CERT_PATH=os.getenv('CERTIFICATE_PATH')
    certificate_path= CERT_PATH+"spntest2024.pfx"
    tenant_id="8c433003-a081-4dfb-a631-100526250b1a"
    client_id="fc5941f1-3052-4ec6-ad3a-cc19d35818a2"
    
    # output
    azureKeyVaultURI = f"https://{azureKeyVault}.vault.azure.net"
    azureKeyVaultCred = CertificateCredential(tenant_id,client_id,certificate_path,password=azureClientSecret)

    return azureKeyVaultCred,azureKeyVaultURI

def getAzureSecret(secretName:str):

    azureKeyVaultCred,azureKeyVaultURI = getAzureCred()
    azureKeyVaultClient = SecretClient(vault_url=azureKeyVaultURI, credential=azureKeyVaultCred)
    azureSecret = azureKeyVaultClient.get_secret(secretName)
    # print(azureSecret.value)

    return azureSecret

# snowflake write to LZ
def getSnowFlakeConn(db,schema,messages):
    db_account = os.environ.get('SNOWFLAKE_ACCOUNT')
    db_username = os.environ.get('SNOWFLAKE_USER')
    db_password = os.environ.get('SNOWFLAKE_SECRET')
    db_database = db
    db_schema = schema 
    db_warehouse = os.environ.get('SNOWFLAKE_WAREHOUSE') # os.environ.get('db_warehouse')
    db_role = os.environ.get('SNOWFLAKE_ROLE') # os.environ.get('db_role')
    conn = 'no connection'
    try:
        # Connect to snowflake db
        conn = sc.connect(
                        account = db_account
                        ,user = db_username
                        ,password = db_password
                        ,database = db_database
                        ,schema = db_schema
                        ,warehouse = db_warehouse
                        ,role = db_role)
        messages.append(f"snowflake connection made to  db: {db} and schema: {schema}")
    except:
        messages.append('FAIL_SIGNAL')
        messages.append(f"Failed to connect to snowflake db: {db} and schema: {schema}")

    return conn, messages

def putSnowflakeDataFrame(db: str, schema: str, tableName: str, df: list[dict] | pd.DataFrame, fileName: str, fileDate: datetime, row_count: int | None = None):
    """A function that uploads a list of dictionaries to the JSONFIELD column, or an entire pandas DataFrame.
    
    TODO: remove usage of row_count parameter
    """
    if row_count:
        warnings.warn("row_count parameter is deprecated; len(df) will be used instead", DeprecationWarning, stacklevel=2)
    row_count = len(df)

    messages = []
    conn,messages = getSnowFlakeConn(db,schema,messages)
    if conn == 'no connection':
        return messages
    
    for attempt in range(1, PUT_SNOWFLAKE_MAX_RETRIES + 1):
        try:
        #create a new dataframe the size of the incoming data with LZ schema columns.
        # set data objects to strings
            uploadDate = str(datetime.now())
            fileDateString = str(fileDate)

            df_new = None
            if isinstance(df, list) and all(isinstance(d, dict) for d in df): # checks if df is json_list form (list of dictionaries)
                # trims out empty dictionaries
                df = [compact_dict(d) for d in df]
                # create a data frame with control columns of correct size
                columns = ['_FILENAME','_FILEDATE','_UPLOADDATE', 'JSONFIELD']
                df_new = pd.DataFrame(columns=columns)
                df_new['JSONFIELD'] = df
                df_new['_FILENAME'] = fileName
                df_new['_FILEDATE'] = fileDateString
                df_new['_UPLOADDATE'] = uploadDate
            elif isinstance(df, pd.DataFrame):
                headerless = list(df.columns) == list(range(len(df.columns)))
                if headerless:
                    # retrieve existing columns from SF table and bind to df
                    query = f"""
                        select 
                            COLUMN_NAME 
                        from {db}.INFORMATION_SCHEMA.COLUMNS 
                        where 
                            TABLE_SCHEMA = '{schema}' and 
                            TABLE_NAME = '{tableName}' and 
                            COLUMN_NAME not in ('_FILENAME', '_FILEDATE', '_UPLOADDATE') 
                        order by ORDINAL_POSITION
                    """
                    results = conn.cursor().execute(query)
                    sf_columns = list(df.columns)
                    if results:
                        sf_columns = list(results.fetch_pandas_all()['COLUMN_NAME'])
                    df.columns = sf_columns
                df = df.rename(str.upper, axis='columns')
                new_columns = ['_FILENAME','_FILEDATE','_UPLOADDATE'] + list(df.columns)
                df['_FILENAME'] = fileName
                df['_FILEDATE'] = fileDateString
                df['_UPLOADDATE'] = uploadDate
                df_new = df[new_columns]

            if df_new is not None:
                # write to sf: https://docs.snowflake.com/developer-guide/python-connector/python-connector-api#write_pandas
                message_write = write_pandas(conn, df_new, tableName, db, schema)
                messages.append(f'putSnowflakeDataFrame(): Insert into snowflake completed for {db}, {schema}, {tableName}, {fileName} - {message_write}')
            else:
                messages.append(f'Unknown type of parameter df: {type(df)}')
            break  # break after sucessfull ingestion.

        except OperationalError as e:
            if attempt <= PUT_SNOWFLAKE_MAX_RETRIES:
                messages.append(f"Network error on attempt {attempt}: {e}. Retrying in {PUT_SNOWFLAKE_RETRY_WAIT_SECONDS} seconds...")
                time.sleep(PUT_SNOWFLAKE_RETRY_WAIT_SECONDS)
                continue
            else:
                messages.append(f"Network error after {PUT_SNOWFLAKE_MAX_RETRIES} retries: {e}")
                messages.append(f'putSnowflakeDataFrame(): Insert into snowflake failed for {db}, {schema}, {tableName}, {fileName}: {e}')
                messages.append('FAIL_SIGNAL')
                break 
        except Exception as e:
            print (f"Error writing to snowflake: ,{fileName}")
            print(e)
            messages.append(f'FAIL_SIGNAL')
            messages.append(f'putSnowflakeDataFrame(): Insert into snowflake failed for {db}, {schema}, {tableName}, {fileName}: {e}')
            break

    try:
        conn.close()
    except:
        pass

    return messages

def readControlTable(db,schema,table_name):
    messages = []
    conn,messages = getSnowFlakeConn(db,schema,messages)
    if conn != 'no connection':
        try:
            cur=conn.cursor()
            if table_name:
                query="select INCREMENTAL_END_VALUE from "+db+"."+schema+".CONTROLTABLE WHERE TABLE_NAME='"+table_name+"' order by RUN_TIME desc limit 1"
                cur.execute(query)
                results=cur.fetchone()
                data=results[0]
                messages.append(f'readControlTable(): Read from snowflake completed for {db}, {schema}, CONTROLTABLE- {data}')
            else:
                query = f"""select TABLE_NAME,INCREMENTAL_END_VALUE from {db}.{schema}.CONTROLTABLE
                            qualify(row_number() over(partition by TABLE_NAME 
                            order by RUN_TIME desc)) = 1;"""
                cur.execute(query)
                results = cur.fetchall()
                data = dict(results)
                messages.append(f'readControlTable(): Read from snowflake completed for {db}, {schema}')                           
            return data,messages
        except Exception as e:
            print (f"Error reading from snowflake: ,{table_name}")
            print(e)
            messages.append(f'FAIL_SIGNAL')
            messages.append(f'Read Data: Read from snowflake failed for {db}, {schema}, {table_name}: {e}')
            return 0,messages
        conn.close()
    return 0,messages

def getFileUploaderConfig(FILEUPLOADER_CONFIG):
    # load from teltools.json
    with open(FILEUPLOADER_CONFIG,'r') as f:
        file_uploader_json = json.load(f,strict=False)
    return file_uploader_json

# sql native client connection, use with pandas read_sql method
def getsqlconn(server,db,un,pw,chunk_size):
    try:
        conn_str = f'mssql+pyodbc://{un}:{pw}@{server}/{db}?driver=ODBC+Driver+18+for+SQL+Server'
        cnxn = sqlalchemy.create_engine(conn_str,isolation_level='READ UNCOMMITTED',connect_args={"timeout": 30,"readonly":True},echo=False).connect().execution_options(stream_results=True,max_buffer=chunk_size)
        message = f'Connection to {server}, {db} established'
        return message, cnxn
    except Exception as e:
        cnxn = None
        message = f'Connection failed for {server}, {db}: {e}'
        return message, cnxn
    

def compact_dict(d: dict):
    # credit: https://www.geeksforgeeks.org/python-removing-nested-none-dictionaries/
    for k, v in list(d.items()):
        if v is None:
            del d[k]
        elif isinstance(v, dict) or isinstance(type(v), ModelMetaclass):
            v = dict(v)
            d[k] = compact_dict(v)
        elif isinstance(v, list) or isinstance(v, set):
            v = list(v)
            for i, x in enumerate(v):
                if isinstance(x, dict) or isinstance(type(x), ModelMetaclass):
                    x = dict(x)
                    v[i] = compact_dict(x)
            d[k] = v
        elif 'pyatlan' in str(type(v)):
            d[k] = str(v)
        else:
            d[k] = v
    return d


def uploadToBlob(Content:str,FileName:str,TargetContainer:str,OverWrite:bool=True,Compress:bool=False,indent:int=2,encoding:str='utf-8'):
    '''
    A helper Function to Upload files Azure Blob Storage.
    Accepts the ContainerClient Object as input.
    Use for Uploading .json Files to Blob Storage.
    Can Compress Files if .gz is provided as FileName in the end or when Compress is set to True.
    Parameters : 
        Content : The Content of the File you want to Upload. Has to be a Python Object (String,List,Dictonary)
        FileName : The Full Path Of the File along with File name eg. Legacy/SAPAPI/Toffee.json
        TargetContainer : ContainerClient Object from Azure
        OverWrite : Overwrite Existing File
        Compress : Turn On Gzip Compression to Save Space
        indent : Format the Json with Indent
        encoding : Change Encoding of Object
    '''
    try:
        serialize =  json.dumps(Content,indent=indent)
    except Exception as e :
        message = f'uploadToBlob(): serialization Failed for : {FileName}\nError : {str(e)}'
        print(message)
        return 1,message
    try:
        if Compress:
            if FileName.endswith('.gz'):
                serialize = gzip.compress(serialize.encode(encoding)) 
            else:
                serialize = gzip.compress(serialize.encode(encoding)) 
                FileName = FileName + '.gz'

        ContainerClient.upload_blob(TargetContainer, FileName, serialize, overwrite=OverWrite, encoding=encoding)
        message = f'uploadToBlob(): Successfully archived: {FileName}'
        print(message)

    except Exception as e :
        message = f'uploadToBlob(): Failed for : {FileName}\nError : {str(e)}'
        print(message)
        return 1,message
    
    return 0,message      

def sendEmail(
        from_email:str,
        to_email:list|str=['ansul.x.dhiman@us.tel.com','varun.x.tiwari@us.tel.com',
                        'stanley.x.correia@us.tel.com',
                        'mohammad.x.yunus@us.tel.com','pritesh.x.gandhi@us.tel.com'],
        cc:list=['farooque.x.shaikh@us.tel.com','david.greenwell@us.tel.com','jay.spiers@us.tel.com'],
        subject:str='',
        email_content: str = '',
        attachments: Optional[List[Attachment]] = None 
    ):
    '''
    A helper Function with Enables Developers to Push Notifications through python.
        from_email : Email Address you want to send Email from.
        to_email : List of Email Addresses you want to send an email to.
        cc : Someone you want to keep as cc?
        subject : Subject of the Email
        email_content : Content of the Email Body
    Note : If no to_email field is provided, the code emails : IT-BI.DW@us.tel.com
    '''
    smtp_server = 'smtp.us.tel.com'
    smtp_port = 25  

    html_content =f"""
    </html>
        <body>
            <p>{email_content}</p>
        </body>
    </html>
    """
    msg = MIMEMultipart()
    msg['From'] = from_email

    if isinstance(to_email,list):
        msg['To'] = ', '.join(to_email)
    else:
        msg['To'] = to_email

    msg['Subject'] = subject
    if cc:
        msg['Cc'] = ', '.join(cc)

    msg.attach(MIMEText(html_content, 'html'))


    # Handle attachments
    if attachments:
        for attachment in attachments:
            filename = attachment.get('filename', 'attachment')
            fileobject = attachment.get('fileobject')
            
            if fileobject:
                fileobject.seek(0)  
                file_data = fileobject.read()
                
                part = MIMEBase('application', 'octet-stream')
                part.set_payload(file_data)
                encoders.encode_base64(part)
                part.add_header(
                    'Content-Disposition',
                    f'attachment; filename={filename}'
                )
                msg.attach(part)

    try:
        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.sendmail(from_email, to_email, msg.as_string())
            print("Email sent successfully!")
    except Exception as e:
        print(f"Error sending email: {e}")

def loadControlTable(db,schema,RunTime,Incremental_Start_Value,Incremental_End_Value,Extraction_Start_Time,Extraction_End_Time,File_Name,MAX_FILE_DATE,ROW_COUNT):
    # TODO: deprecate MAX_FILE_DATE argument
    messages = []
    conn,messages = getSnowFlakeConn(db,schema,messages)
    if conn != 'no connection':
        try:
            columns = ['RUN_TIME','INCREMENTAL_START_VALUE','INCREMENTAL_END_VALUE','EXTRACTION_START_TIME','EXTRACTION_END_TIME','TABLE_NAME','MAX_FILE_DATE','ROW_COUNT']
            data = [RunTime,Incremental_Start_Value,Incremental_End_Value,Extraction_Start_Time,Extraction_End_Time,File_Name,MAX_FILE_DATE,ROW_COUNT]
            df_data = [dict(zip(columns, data))]
            df_write = pd.DataFrame(data=df_data)
            tableName='CONTROLTABLE'
            # write to sf: https://docs.snowflake.com/developer-guide/python-connector/python-connector-api#write_pandas
            message_write = write_pandas(conn,df_write,tableName,db,schema)
            messages.append(f'loadControlTable(): Insert into snowflake completed for {db}, {schema}, {tableName}, {File_Name} - {message_write}')
        except Exception as e:
            print (f"Error writing to snowflake: ,{File_Name}")
            print(e)
            messages.append(f'FAIL_SIGNAL')
            messages.append(f'putSnowflakeDataFrame(): Insert into snowflake failed for {db}, {schema}, {tableName}, {File_Name}: {e}')
        conn.close()
    return messages

def get_atlan_client():
    atlan_token = getAzureSecret('ATLAN-ADMIN-TOKEN').value
    tenant_url = 'https://tel.atlan.com'
    client = AtlanClient(
        base_url=tenant_url,
        api_key=atlan_token,
    )
    AtlanClient.set_default_client(client)
    return client

def create_logger(name=__name__):
    logger = logging.getLogger(name)
    handler = logging.StreamHandler()
    # formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    # handler.setFormatter(formatter)
    logger.addHandler(handler)
    logger.setLevel(logging.DEBUG)
    return logger

def dbt_to_atlan(dbt_command: str, logger: typing.Optional[logging.Logger] = None):
    """
    Takes a dbt command ex `dbt run --select tag:kanbanize` and takes the latest results and updates the corresponding assets in atlan.

    Args:
        dbt_command (str): The dbt command used in the Prefect/Astro script. ie `dbt run --select tag:kanbanize`
        logger (logging.Logger): Optionally pass in the logger from the Prefect context
    """
    if not logger:
        logger = create_logger('dbt_atlan_logger')

    client = get_atlan_client()
    AtlanClient.set_default_client(client)

    # some dbt commands are ran with double spaces but they are registered in dbt_artifacts with a single space 
    # so the command paramater must trim the double spaces into single spaces for the query to match
    dbt_command = re.sub(' +', ' ', dbt_command)

    db = os.environ['SNOWFLAKE_SILVER']
    query = f"""
        select *
        from {db}.TEH_DATA_OPS.TEL_DBT_LOG
        where INVOCATION_COMMAND = '{dbt_command}'
            or array_contains('{dbt_command}'::VARIANT, TEST_INVOCATION_COMMANDS)
    """

    conn, messages = getSnowFlakeConn(db, 'CONTROL', [])
    df_models = conn.cursor().execute(query).fetch_pandas_all()
    logger.info(f'Found {len(df_models)} dbt models')
    
    for idx, row in df_models.iterrows():
        invocation_id = row['COMMAND_INVOCATION_ID']
        node_id = row['NODE_ID']
        db = row['DATABASE'].upper()
        db = db_mapping.get(db, db)
        schema = row['SCHEMA'].upper()
        alias = row['ALIAS'].upper()
        tags = row['TAGS']
        tags = set(ast.literal_eval(tags))
        run_dt = row['RUN_STARTED_AT']
        run_unix_seconds = (run_dt - pd.Timestamp('1970-01-01')) // pd.Timedelta('1milliseconds')
        compile_dt = row['COMPILE_STARTED_AT']
        compile_unix_seconds = (compile_dt - pd.Timestamp('1970-01-01')) // pd.Timedelta('1milliseconds')
        status = row['STATUS'].title()
        status = status if status == 'Success' else 'Fail'
        test_results_str = row['TEST_RESULTS'] if row['TEST_RESULTS'] else '{}'
        test_results_str = test_results_str.replace('"status": "error"', '"status": "fail"')
        test_results = ast.literal_eval(test_results_str)
        test_statuses = [t.get('status') for t in test_results]
        test_statuses_str = '["' + '","'.join(test_statuses) + '"]'

        atlan_qname = f'default/snowflake/1754682100/{db}/{schema}/{alias}'
        if db == 'PUB':
            object_updater = View.updater(
                name=alias,
                qualified_name=atlan_qname,
            )
        else:
            object_updater = Table.updater(
                name=alias,
                qualified_name=atlan_qname,
            )

        object_updater.asset_dbt_job_name = invocation_id # uses invocation id
        object_updater.asset_dbt_job_status = status # Success or Fail
        if not np.isnan(compile_unix_seconds):
            object_updater.asset_dbt_job_last_run = compile_unix_seconds # Unixtime with millisecond
        elif not np.isnan(run_unix_seconds):
            object_updater.asset_dbt_job_last_run = run_unix_seconds # Unixtime with millisecond
        else:
            object_updater.asset_dbt_job_last_run = None # Unixtime with millisecond
        object_updater.asset_dbt_tags = tags # make sure this doesnt overwrite
        object_updater.asset_dbt_test_status = test_statuses_str
        
        # meant to replicate the Certificate Update playbook at https://tel.atlan.com/governance/playbooks/test/overview
        if object_updater.certificate_status != CertificateStatus.DEPRECATED:
            if status == 'Success' and set(test_statuses) == {'pass'}:
                object_updater.certificate_status = CertificateStatus.VERIFIED
            elif status == 'Fail' or 'fail' in test_statuses or 'warn' in test_statuses:
                object_updater.certificate_status = CertificateStatus.DRAFT
            else:
                object_updater.certificate_status = None
        response = client.asset.save(object_updater)
        logger.debug(f'Updated asset {atlan_qname}')
    logger.info(f'Updated {len(df_models)} dbt models in Atlan.')

def update_atlan_domain(domain_guid: str, logger: typing.Optional[logging.Logger] = None):
    """
    Takes the guid of an Atlan Domain and adds/updates the data products according to the linked schema asset. The guid can be found in the URL of the Domain overview page.

    Args:
        domain_guid (str): The dbt command used in the Prefect/Astro script. ie `dbt run --select tag:kanbanize`
        logger (logging.Logger): Optionally pass in the logger from the Prefect context
    """
    if not logger:
        logger = create_logger('atlan_domains_logger')

    client = get_atlan_client()
    AtlanClient.set_default_client(client)
    
    domain = client.asset.get_by_guid(domain_guid)
    logger.info(f'Matched {domain.name} domain.')
    assert domain.qualified_name
    # domain should be linked to an existing schema in Snowflake
    request = (
        FluentSearch()
        .where(CompoundQuery.active_assets())
        .where(CompoundQuery.asset_type(Schema))
        .where(Table.QUALIFIED_NAME.startswith('default/snowflake/1754682100/')) 
        .where(Asset.DOMAIN_GUIDS.eq(domain.guid))
    ).to_request()
    domain_schemas = list(client.asset.search(request))
    if not domain_schemas:
        logger.warning('Did not find any linked schemas. Make sure to go to the asset overview of the corresponding schema and make sure the "Domain" is populated.')
        return
    logger.info(f'Found {len(domain_schemas)} linked schemas.')


    # loop through each Table/View in each linked schema to either create or update the linked data product with latest assets and "DQ" certification status
    for schema in domain_schemas:
        logger.info(f'Searching assets in {schema.name}.')
        # look for all the Tables/Views in the given schema which will tie 1-1 to a data product as the output port
        request = (
            FluentSearch()
            .where(CompoundQuery.active_assets())
            .where(CompoundQuery.asset_type(Table) | CompoundQuery.asset_type(View))
            .where(Table.QUALIFIED_NAME.startswith(schema.qualified_name + '/')) 
        ).to_request()
        schema_assets = list(client.asset.search(request))
        if not schema_assets:
            logger.warning('Did not find any related assets. Double check if there are any tables/views in the schema and Snowflake and then wait for the Atlan workflow to create the assets.')
            return
        logger.debug(f'Found {len(schema_assets)} related assets.')

        for base_asset in schema_assets:
            # gather all the Atlan details of the SF asset
            logger.debug(f'Processing {base_asset.qualified_name}.')
            starting_guid = base_asset.guid
            output_index = (
                FluentSearch()
                .where(CompoundQuery.active_assets())
                .where(Column.GUID.eq(starting_guid))
            ).to_request()
            output_ports = list(client.asset.search(output_index))
            assert type(output_ports) is list and len(output_ports) > 0
            output_guid = output_ports[0].guid
            output_port = client.asset.get_by_guid(output_guid)

            # gather all the upstream assets
            request = FluentLineage(
                starting_guid=starting_guid,
                depth=1,
                direction=LineageDirection.UPSTREAM,
                size=100,
                includes_on_results=Asset.NAME,
            ).request
            lineage_response = client.asset.get_lineage_list(request)

            # generate an acceptable list of upstream assets to be used for data products input ports
            guids_bool = Column.GUID.eq(starting_guid)
            for res in lineage_response:
                if res.type_name in ('Table', 'View', 'PowerBI'):
                    guids_bool = guids_bool | Column.GUID.eq(res.guid)
            input_index = (
                FluentSearch()
                .where(CompoundQuery.active_assets())
                .where(guids_bool)
            ).to_request()
            input_ports = list(client.asset.search(input_index))
            logger.debug(f'Found {len(input_ports)} upstream assets.')
            
            # search all of the existing data products to look for any that are already linked to the SF asset 
            found_data_product = None
            product_index = (
                FluentSearch()
                .where(CompoundQuery.active_assets())
                .where(CompoundQuery.asset_type(DataProduct))
                .where(Asset.QUALIFIED_NAME.startswith(domain.qualified_name))
                .include_on_relations(Asset.OUTPUT_PORT_DATA_PRODUCTS)
                .include_on_results(Asset.OUTPUT_PORT_DATA_PRODUCTS)
            ).to_request()
            existing_products = list(client.asset.search(product_index))
            for existing_product in existing_products:
                dp = client.asset.get_by_guid(existing_product.guid, ignore_relationships=False)
                assert type(dp) is DataProduct and type(dp.output_ports) is list and len(dp.output_ports) > 0
                dp_output_port = dp.output_ports[0]
                dp_output_port = client.asset.get_by_guid(dp_output_port.guid)
                if dp_output_port.qualified_name == base_asset.qualified_name:
                    found_data_product = dp
                    break
            
            # if there is an existing data product already use the update method, otherwise create a new data product
            if found_data_product and found_data_product.name and found_data_product.qualified_name:
                action = 'Updated'
                product = DataProduct.updater(
                    name=found_data_product.name,
                    qualified_name=found_data_product.qualified_name,
                )
            else:
                action = 'Created'
                product = DataProduct.creator(
                    name=base_asset.name,
                    domain_qualified_name=domain.qualified_name,
                    asset_selection=input_index,
                )
            product.output_ports = output_ports
            product.certificate_status = output_port.certificate_status
            product.daap_visibility = DataProductVisibility.PUBLIC
            response = client.asset.save(product)
            logger.debug(f'{action} product {product.name} in domain {domain.name} with {len(input_ports)} linked assets.')
        logger.info(f'Done with {schema.name} schema. {len(schema_assets)} related assets.')
    logger.info(f'Done with {domain.name} domain.')
    
class ConfigValidationError(Exception):
    """Custom Exception for configuration error"""
    pass
def validate_config(section,config):
    if not config:
        raise ConfigValidationError(f"Missing config for '{section}'")
    required_fields = ['fileshare','table','schema','file_pattern','is_incremental','delimiter','skip_header']
    for field in required_fields:
        if field not in config or not config:
            raise ConfigValidationError(f"Missing or blank config param '{field}' in section '{section}'")   
    if 'securables' in config:
        securables = config['securables']
        if 'username' not in securables:
            raise ConfigValidationError(f"Missing or blank 'username' in section '{section}'")
        if 'password-name' not in securables:
            raise ConfigValidationError(f"Missing or blank 'password-name' in section '{section}'")

def load_config(config_file):
    """Load the configuration from a JSON file."""
    try:
        with open(config_file, 'r',encoding='utf-8') as f:
            config =  json.load(f)
            print(f"Configuration loaded successfully")
            return {"status": True, "message": "Configuration loaded successfully", "data": config}
    except Exception as e:
        print(f"Error loading configuration file: {e}")
        return {"status": False, "message": f"Error loading configuration file: {e}", "data": None}

def load_control_table(CURRENT_TIMESTAMP, Incremental_Start_Value, Incremental_End_Value, Extraction_Start_Time, Extraction_End_Time, table_name, MAX_FILE_DATE, rows_loaded, schema, db):
    """Load data into the control table in Snowflake and return status messages."""
    try:
        messages = loadControlTable(
            db, 
            schema, 
            CURRENT_TIMESTAMP, 
            Incremental_Start_Value, 
            Incremental_End_Value, 
            Extraction_Start_Time, 
            Extraction_End_Time, 
            table_name, 
            MAX_FILE_DATE, 
            rows_loaded
        )
        print(f'loadControlTable(): {messages}')

        if "FAIL_SIGNAL" in messages:
            return {"status": False,"message":messages}  
        else:
            return {"status": True,"message":messages}
    except Exception as e:
        error_message = f"Error in load_control_table {table_name}: {e}"
        print(error_message)
        return {"status": False, "message":error_message} 

def read_runtime_config(db, schema):
    try:
        msg = []
        runtimeConfig , msg = readControlTable(db,schema,None)
        print(f'read_runtime_config(): {runtimeConfig} \n')
        if "FAIL_SIGNAL" in msg:
            return {"status": False, "message":msg,"data":None}
        else:            
            return {"status": True, "message":msg,"data":runtimeConfig}         
    except Exception as e:
        return {"status": False, "message":e,"data":None} 

def process_file_content(
        content, file_name, 
        last_extraction_time, db, schema, table, 
        delimiter, skip_header, 
        ignore_header, section, RUN_TIME,
        dtype=None, file_format=None, sheet_name = None, 
        convert_to_json = False, convert_headers_to_number = False, 
        header_row = None
        ):
    """Convert content into a DataFrame and upload to Snowflake."""
    messages = []
    row_count = 0    
    try:
        if file_format == 'xlsx':
            if sheet_name :
                data_io = content if isinstance(content, io.BytesIO) else io.BytesIO(content)
                df = pd.read_excel(data_io, dtype=dtype, engine='openpyxl', sheet_name=sheet_name)
            else:
                data_io = content if isinstance(content, io.BytesIO) else io.BytesIO(content)
                df = pd.read_excel(data_io, dtype=dtype, engine='openpyxl')

            if ignore_header:
                df.columns = list(range(len(df.columns)))   

        elif file_format == 'ndjson':
            df = [json.loads(line) for line in content.splitlines() if line.strip()]
        
        elif file_format == 'json' :
            df = json.loads(content)

            if isinstance(df, dict):
                df = [df]

        else:
            data_io = io.StringIO(content)
            
            if skip_header:
                header = None 
            elif header_row:
                header = header_row
            else:
                header = 'infer' 
            
            dtype_selection = str if dtype else None
            
            df = pd.read_csv(data_io, delimiter=delimiter, header=header, dtype=dtype_selection)
            if ignore_header:
                df.columns = list(range(len(df.columns)))

        if convert_headers_to_number: #shift header to row and rename header to 0,1,2 ...
            df = df.reset_index(drop=True)
            df.loc[-1] = df.columns
            df.index = df.index + 1
            df = df.sort_index()
            df.columns = range(df.shape[1])

        if file_format in ('xlsx', 'csv') or file_format is None:
            df = df.astype(str)
            df.replace('nan',None,inplace=True)
        
        if section.startswith('Prophet'): #aligning filename with existing process as parsed filename is used in dbt models
            file_name = f'{table}/{file_name}.gz'

        if convert_to_json:
            df = [ {k.replace("\n", " "): v for k, v in record.items()} for record in json.loads(df.to_json(orient='records')) ]
            
        messages = putSnowflakeDataFrame(
            db=db,
            schema=schema,
            tableName=table,
            df=df,
            fileName=file_name,
            fileDate=RUN_TIME
        )
        row_count = len(df)
        if "FAIL_SIGNAL" in messages:
            return {"status": False, "message": f"Error processing file content: {file_name} Error: {messages}", "data": row_count}
        else:
            # print('Succesfully loaded in Snowflake')            
            return {"status": True, "message": f"{messages}", "data":row_count}
        
    except Exception as e:
        print(f"Error processing file content: {file_name}, Error: {e}")
        return {"status": False, "message": f"Error processing file content: {file_name} Error: {e}", "data": row_count}

def formatFileDate(run_timestamp: datetime) -> str:
    """
    Formats a datetime object to a string with milliseconds precision (YYYY-MM-DD HH:MM:SS.sss).
    Used to align _FILEDATE in base tables and RUN_TIME in control_table. 
    Args:
        run_timestamp (datetime): The datetime object to format.

    Returns:
        str: Formatted datetime string up to milliseconds.
    """
    formatted_dt = run_timestamp.strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]
    return formatted_dt