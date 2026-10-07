import include.Python.TELTools as tt
import pandas as pd
import sys
import os.path
import logging
import TELTools as TT
from azure.storage.blob import BlobClient, ContainerClient, __version__
import io
from datetime import datetime, timedelta, timezone
import gzip


api_call_datetimestamp = datetime.now()
log_path = "/usr/local/airflow/include/Python/logs/legacy_migration/blob_to_sf"
CURRENT_TIMESTAMP = str(datetime.now()).replace(" ","_").replace(":","_").replace(".","_")

def get_logger(logger_name):
    global log_path 
    log_file = f'blob_to_sf_{logger_name}_{CURRENT_TIMESTAMP}.log'
    logger = logging.getLogger(__name__)
    logger.setLevel(logging.INFO)
    file_location = os.path.join(log_path,'loggers',log_file)
    file_handler = logging.FileHandler(file_location)
    file_handler.setLevel(logging.INFO)
    file_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
    logger.addHandler(file_handler)

    return logger
def table_exists(db_name, schema_name, table_name):
    try:
        messages = []
        conn,messages = TT.getSnowFlakeConn(db_name,schema_name,messages)

        query = f"""
        SELECT COUNT(*)
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = '{schema_name.upper()}' 
        AND TABLE_NAME = '{table_name.upper()}'
        AND TABLE_CATALOG = '{db_name.upper()}'
        """
        #print(query)
        cursor = conn.cursor()
        cursor.execute(query)
        result = cursor.fetchone()
        cursor.close()
        if result[0] > 0:
            print(f"Table '{db_name}.{schema_name}.{table_name}' exists.")
            return True
        else:
            print(f"Table '{db_name}.{schema_name}.{table_name}' does not exist.")
            return False
    except Exception as e:
        return False
    
def post_to_snowflake(sf_db,sf_schema,sf_table,json_list,file_name,row_count):
    db = sf_db
    schema = sf_schema
    tableName = sf_table
    messages = [f'post_to_snowflake() method failed for {file_name}']
    try:
        messages = TT.putSnowflakeDataFrame(db,schema,tableName,json_list,file_name,api_call_datetimestamp,row_count)
        print(f'TT.putSnowflakeDataFrame(): {messages}')
        if "FAIL_SIGNAL" in messages:
            return 1,messages
        else:
            return 0,messages
    except Exception as e:
        print (f"Error writing to snowflake: ,{file_name}")
        print(e)
        return 1,messages

def main(blob_location,snowflake_schema,snowflake_table):
    target_name =  f'{snowflake_schema}_{snowflake_table}'
    snowflake_schema,snowflake_table = snowflake_schema.upper(),snowflake_table.upper()
    logger = get_logger(target_name)
    logger.info(f'Starting Snowflake Ingestion for {target_name}')
    try:
        snowflake_db = os.getenv("SNOWFLAKE_LZ")
        sasURLTGT = TT.getAzureSecret("AZURE-STORAGE-TELUSDW-SAS").value
        tgt_container = ContainerClient.from_container_url(sasURLTGT)

        if table_exists(snowflake_db, snowflake_schema, snowflake_table):
            logger.info("The table exists.")              
            #blb_gz = "TELUSDW/TEA_ETL/SSISPrefixes"
            #blb_non_gz = 'TELUSDW/TELIS_Live/TWHINH225201'
            blobs_list = ContainerClient.list_blobs(tgt_container,name_starts_with=blob_location) 
            final_status = []
            for blob in blobs_list:    
                logger.info(f"Processing blob: {blob.name}")
                try:
                    blob_content = ContainerClient.download_blob(tgt_container,blob.name).readall()
                    blob_bytes_io = io.BytesIO(blob_content)
                    print(type(blob_content))
                    if '.gz' in blob.name:
                        logger.info("Blob is compressed")
                        # Dec#ompress the gzip data
                        with gzip.open(blob_bytes_io) as gz:
                            file = gz.read()        
                        # Decode the decompressed data
                        blob_decompress = file.decode('utf-8-sig')
                        json_list_gz = pd.read_json(blob_decompress,typ='series',orient='records').to_list()
                        row_count = len(json_list_gz)
                        failure,return_messages = post_to_snowflake(snowflake_db,snowflake_schema,snowflake_table,json_list_gz,blob.name,row_count)
                    else:
                        logger.info("Blob is not compressed")
                        blob_decode = blob_content.decode('utf-8-sig')
                        json_list_nongz = pd.read_json(blob_decode,typ='series',orient='records').to_list()
                        row_count = len(json_list_nongz)
                        failure,return_messages = post_to_snowflake(snowflake_db,snowflake_schema,snowflake_table,json_list_nongz,blob.name,row_count)
                    if failure:
                        logger.error(f"Failed to process blob: {blob.name}. Messages: {return_messages}")
                        final_status.append((target_name, blob.name,row_count,"Fail",return_messages))
                    else:
                        logger.info(f"Successfully processed blob: {blob.name}, Messages: {return_messages}")
                        final_status.append((target_name, blob.name,row_count,"Success",return_messages))
                        
                except Exception as e:
                    logger.error(f"Error processing blob {blob.name}: {e}")
                    final_status.append((target_name, blob.name,"n/a","Fail",e))
                
            Audit_df = pd.DataFrame(final_status,columns = ['snowflake_target','blob_name','records','status','msg'])
            Audit_df.to_csv(os.path.join(log_path,f"{target_name}_Audit_{CURRENT_TIMESTAMP}.csv"),index = False)
            Count_df =Audit_df.groupby(['snowflake_target']).agg({'records': 'sum','status':pd.Series.unique}).reset_index()
            Count_df.to_csv(os.path.join(log_path,f"{target_name}_Final_{CURRENT_TIMESTAMP}.csv"),index = False)

            if "Fail" in Audit_df.status.unique():
                raise Exception('Data Upload Failed')
            else:
                logger.info("Data Uploaded Sucessfully")
        else:
            logger.error("The table does not exist.")
            raise Exception('The table does not exist.')
    except Exception as e:
        logger.critical(f"Critical error in main processing: {e}")  
        raise Exception('Data Upload Failed') 

if __name__ == "__main__":
    args = sys.argv[1:]
    blob_location:str = args[0] #blob path (eg: TELUSDW/TEA_ETL/SSISPrefixes)
    snowflake_schema:str = args[1].upper() 
    snowflake_table:str = args[2].upper()
    
    if not all([blob_location,snowflake_schema,snowflake_table]):
        raise Exception('Failed while passings Arguments')

    main(blob_location,snowflake_schema,snowflake_table) 