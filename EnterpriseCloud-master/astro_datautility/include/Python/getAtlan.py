import sys
from datetime import datetime as dt
import time
import os
import json
import pyatlan.model.assets
from pyatlan.model.assets import Asset
from pyatlan.model.fluent_search import FluentSearch, CompoundQuery
import include.Python.TELTools as TT
import typing
import logging
import argparse

ENTERPRISECLOUD_REPO = os.environ.get('ENTERPRISECLOUD_REPO', 'F:\\Shares')
LZ = os.getenv('SNOWFLAKE_LZ', 'LZ_DEV')
SCHEMA = 'ATLAN'

def get_asset_data(table_name=None, full_refresh=False, logger: typing.Optional[logging.Logger] = None):
    """
    Ingests metadata from Atlan into Snowflake by looping over configured entities (or a specific entity) and extracts the specified metadata 
    attributes following a CDC pattern since a previous ingestion. This script relies on configured entries in the Configuration/TelTools_Atlan.json 
    file which is made up of a list of dictionaries. Each entry represents a different type of asset in Atlan and must have two fields: 
    SF_TABLE_NAME (name of the destination table in Snowflake) and ASSET_TYPE (a type of Atlan asset https://developer.atlan.com/models/). 
    Optionally you can configure a list of attributes to be included in the ingestion. There are hundreds of possible attributes differing between 
    each type of asset and it dramatically slows down the api if all are included. If more attributes are added in the future, make sure to rerun 
    the table using the --full_refresh (-f) flag to go back and pull the new attributes for old assets.

    Args:
        table_name (str): The name of the configured Snowflake table to be updated. If a table name is not provided, it will ingest all entities. 
            Make sure this is added in a Configuration/TelTools_Atlan.json entry.
        full_refresh (bool): Flag to reingest all historical metadata. Default is False meaning it will only load changes from last run via the CONTROLTABLE.
        logger (logging.Logger): Optionally pass in the logger from the Prefect context
    """
    if not logger:
        logger = TT.create_logger('get_asset_data')
    
    file_date = dt.now()
    file_date_epoch = file_date.timestamp() * 1000 # atlan measures epochs in milliseconds

    config_path = '/usr/local/airflow/include/Configuration/TelTools_Atlan.json'
    with open(config_path, 'r') as f:
        config = json.load(f)

    skipped_tables = True
    for dataset in config['Datasets']:
        try:
            sf_table_name = dataset['SF_TABLE_NAME'].upper() # name of corresponding table in Snowflake
            asset_type_name = dataset['ASSET_TYPE'] # name of pyatlan.model.assets module
            include_on_results = dataset.get('INCLUDE_ON_RESULTS', [])
        except KeyError as e:
            # SF_TABLE_NAME and ASSET_TYPE are required, whereas the includes can default to empty lists
            missing_config = e.args[0]
            if missing_config == 'SF_TABLE_NAME':
                logger.error('Error: Config entry missing a SF_TABLE_NAME value. Please provide the name of the LZ table.')
            if missing_config == 'ASSET_TYPE':
                logger.error('Error: Config entry missing a ASSET_TYPE value. Please provide the name of the pyatlan.model.assets module. You can find a full list of asset types here: https://developer.atlan.com/models/')
            raise e
        if table_name:
            # if a specific table name was passed, skip other configs
            if table_name == sf_table_name:
                logger.debug('Matched table_name')
            else:
                continue
        
        # if we made it past the `continue` statement, either we matched a table name or looped by default
        skipped_tables = False
        logger.info(f'Processing {sf_table_name=}, {asset_type_name=}')

        try:
            # gets the literal class object to be used
            asset_type = getattr(pyatlan.model.assets, asset_type_name)
        except NameError as e:
            logger.error(f'Error: asset type "{asset_type_name}" is not found in pyatlan.model.assets')
            raise e
        
        # timestamp of last run measured in milliseconds
        if full_refresh:
            logger.debug('full_refresh set to True')
            incremental_epoch = 0.0
        else:
            try:
                # by default we will look in the CONTROLTABLE for the last timestamp we ingested up to
                incremental_end_value, messages = TT.readControlTable(db=LZ, schema='ATLAN', table_name=sf_table_name)
                if incremental_end_value and isinstance(incremental_end_value, str):
                    incremental_epoch = float(incremental_end_value)
                    logger.debug('incremental_epoch pulled from CONTROLTABLE')
                else:
                    logger.error('Failed to pull incremental_epoch from CONTROLTABLE')
                    incremental_epoch = 0.0
            except:
                logger.error('Error: Failed to pull incremental_epoch from CONTROLTABLE')
                incremental_epoch = 0.0
        logger.debug(f'Set {incremental_epoch=}')

        search = FluentSearch()
        # filters the search to find recent changes to active assets of provided class type 
        search = search.where(CompoundQuery.asset_type(asset_type))
        search = search.where(Asset.UPDATE_TIME.gte(incremental_epoch))
        search = search.where(Asset.UPDATE_TIME.lte(file_date_epoch))

        # Atlan doesn't provide all asset attributes by default, instead they are requested to be included
        for attr_name in include_on_results:
            # universal attributes are stored on the "Asset" class object so we check there as a back up
            try:
                attr = getattr(asset_type, attr_name.upper())
            except:
                attr = getattr(Asset, attr_name.upper())
            search = search.include_on_results(attr)
        
        client = TT.get_atlan_client()

        request = search.to_request()
        logger.debug(f'Searching "{asset_type_name}" assets between {dt.fromtimestamp(incremental_epoch/1000)} and {file_date}')
        t0 = time.time()
        results = client.asset.search(request)
        t1 = time.time()
        row_count = results.count
        logger.debug(f'Found {row_count} search results after {round(t1-t0, 5)} seconds')
        
        data = [dict(asset) for asset in results] # formats results into json list format as expected by TT.putSnowflakeDataFrame()
        file_name = f'{asset_type_name}_{file_date.isoformat()}_1' # manually added a _1 suffix in case chunking is later implemented
        messages = TT.putSnowflakeDataFrame(
            db=LZ, 
            schema=SCHEMA, 
            tableName=sf_table_name, 
            df=data, 
            fileName=file_name, 
            fileDate=file_date
        )
        if 'FAIL_SIGNAL' in messages:
            raise Exception('\n'.join(messages))
        logger.debug(messages[-1])

        messages = TT.loadControlTable(
            db=LZ,
            schema=SCHEMA,
            RunTime=file_date.isoformat(),
            Incremental_Start_Value=incremental_epoch,
            Incremental_End_Value=file_date_epoch,
            Extraction_Start_Time=dt.fromtimestamp(t0).isoformat(),
            Extraction_End_Time=dt.fromtimestamp(t1).isoformat(),
            File_Name=sf_table_name,
            MAX_FILE_DATE=file_date,
            ROW_COUNT=row_count
        )
        if 'FAIL_SIGNAL' in messages:
            raise Exception('\n'.join(messages))
        logger.debug(messages[-1])

        logger.info(f'Successfully updated {sf_table_name}\n')
    
    if table_name and skipped_tables:
        logger.warning(f'Nothing to do. Never matched table "{table_name}" in config entries.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Ingests metadata from Atlan into Snowflake.')
    parser.add_argument('-t', '--table_name', type=str, help='The name of the configured Snowflake table to be updated. If a table name is not provided, it will ingest all entities.')
    parser.add_argument('-f', '--full_refresh', action='store_true', help='Flag to reingest all hstorical metadata. Default is False meaning it will only load changes from last run.')
    args = parser.parse_args()
    get_asset_data(table_name=args.table_name, full_refresh=args.full_refresh)
