import logging
import os
from datetime import datetime, timezone
import json 
import requests
from bs4 import BeautifulSoup as bs
import include.Python.TELTools as TT
import time
import typing
import warnings
# this warning is raised when using the verify=False argument in the requests call. Ignored due to lack of SSL certification 
warnings.filterwarnings('ignore', message="Unverified HTTPS request is being made to host 'telusit.kanbanize.com'. Adding certificate verification is strongly advised. See: https://urllib3.readthedocs.io/en/1.26.x/advanced-usage.html#ssl-warnings")

API_KEY =  TT.getAzureSecret('KANBANIZE-API-KEY').value
headers = {
    'accept': 'application/json',
    'apikey': API_KEY
}

RUN_TIME = datetime.now()
CURRENT_TIMESTAMP = str(RUN_TIME).replace(" ","_").replace(":","_").replace(".","_")
LZ_DB = os.environ["SNOWFLAKE_LZ"]
LZ_SCHEMA = "KANBANIZE"

def main(logger: typing.Optional[logging.Logger] = None):
    if not logger:
        logger = TT.create_logger('kanbanize_logger')

    db = os.environ['SNOWFLAKE_LZ']
    schema = 'KANBANIZE'
    fileDate = datetime.now()
    
    config,msg = TT.readControlTable(LZ_DB,LZ_SCHEMA,None)
    if not config:
        raise Exception(f"Error while fetching Runtime Config from Control Table: {msg}")
    utc_dt = fileDate.astimezone(timezone.utc)
    last_modified_from = config.get('last_modified_from', '1970-01-01T00:00:00Z')
    next_modified_from = utc_dt.isoformat(timespec='seconds').replace('+00:00', 'Z')
    logger.info(f'Processing changes between {last_modified_from} and {next_modified_from}')

    tableName = 'CARDS'
    logger.info(f'Processing {tableName}')
    for state in ('active', 'archived', 'discarded'):
        page_num = 1
        page_count = 1
        fields = 'card_id,title,description,custom_id,owner_user_id,type_id,size,priority,color,deadline,reporter,created_at,revision,last_modified,\
            in_current_position_since,board_id,workflow_id,column_id,lane_id,section,position,last_column_id,last_lane_id,version_id,archived_at,reason_id,\
            discard_comment,discarded_at,is_blocked,block_reason,current_block_time,current_logged_time,current_cycle_time,child_card_stats,finished_subtask_count,\
            unfinished_subtask_count,comment_count,first_start_time,first_end_time,last_start_time,last_end_time'
        counter= 0
        while page_num <= page_count:
            url = f'https://telusit.kanbanize.com/api/v2/cards?last_modified_from={last_modified_from}&state={state}&page={page_num}&per_page=1000&fields={fields}&expand=custom_fields,tag_ids'
            response = requests.get(url=url, headers=headers, verify=False)
            try:
                assert response.status_code == 200
            except AssertionError as e:
                logger.error(f'{state} {tableName} {response = }')
                raise e
            results = json.loads(response.text)
            page_count = results['data']['pagination']['all_pages']
            logger.info(f'Processing page {page_num} of {page_count} {state} {tableName}')
            data = results['data']['data']
            for row in data:
                card_id = row.get('card_id')
                comment_count = row.get("comment_count")
                #fetching comments if exists
                if comment_count >0:
                    #added to pause when 25 api requests are made within 1 minute
                    counter+=1
                    if counter>=25:
                        logging.debug("Working on api request. Please wait...")
                        time.sleep(60) #minimum to make another api request 
                        counter =0
                    comments_url = f'https://telusit.kanbanize.com/api/v2/cards/{card_id}/comments'
                    comments_response = requests.get(url=comments_url, headers=headers, verify=False)
                    if comments_response.status_code == 200:
                        row['comments'] = comments_response.json().get("data",[])
                description_html = row.get('description', '')
                row['description_html'] = description_html
                description_txt = description_html
                if '<' in description_html:
                    description_txt = bs(description_html, features='lxml').get_text('\n')
                row['description'] = description_txt
                row['state'] = state
            fileName = f'{fileDate.isoformat()}-{tableName}_{state}-{page_num}.json'
            data = [{k: str(v) for k, v in TT.compact_dict(d).items()} for d in data]
            messages = TT.putSnowflakeDataFrame(db, schema, tableName, data, fileName, fileDate)
            assert 'FAIL_SIGNAL' not in messages
            page_num += 1

    # the rest of the entities don't return 1000s of entries nor do they have different statuses to pull together making a simpler api request
    for entity in ('tags', 'users', 'customFields'):
        tableName = entity.upper()
        logger.info(f'Processing {tableName}')
        url = f'https://telusit.kanbanize.com/api/v2/{entity}?last_modified_from={last_modified_from}'
        response = requests.get(url=url, headers=headers, verify=False)
        assert response.status_code == 200
        results = json.loads(response.text)
        data = results['data']
        fileName = f'{fileDate.isoformat()}-{tableName}-1.json'
        data = [{k: str(v) for k, v in TT.compact_dict(d).items()} for d in data]
        messages = TT.putSnowflakeDataFrame(db, schema, tableName, data, fileName, fileDate)
        assert 'FAIL_SIGNAL' not in messages
        
        if entity == 'customFields' and data:
            dropdown_field_ids = [d['field_id'] for d in data if d['type'] == 'dropdown']
            tableName = 'CUSTOMFIELDS_VALUES'
            for field_id in dropdown_field_ids:
                url = f'https://telusit.kanbanize.com/api/v2/customFields/{field_id}/allowedValues'
                response = requests.get(url=url, headers=headers, verify=False)
                assert response.status_code == 200
                results = json.loads(response.text)
                fields_data = results['data']
                fileName = f'{fileDate.isoformat()}-{tableName}-1.json'
                for row in fields_data:
                    row['field_id'] = field_id
                fields_data = [{k: str(v) for k, v in TT.compact_dict(d).items()} for d in fields_data]
                messages = TT.putSnowflakeDataFrame(db, schema, tableName, fields_data, fileName, fileDate)
                assert 'FAIL_SIGNAL' not in messages

    config['last_modified_from'] = next_modified_from
    EXTRACTION_END_TIME = datetime.now()
    
    load_control_table_status= TT.load_control_table(
        CURRENT_TIMESTAMP=CURRENT_TIMESTAMP,
        Incremental_Start_Value=last_modified_from,
        Incremental_End_Value=next_modified_from,
        Extraction_Start_Time=str(RUN_TIME),
        Extraction_End_Time=str(EXTRACTION_END_TIME),
        table_name="last_modified_from",
        MAX_FILE_DATE=str(RUN_TIME),
        rows_loaded="na",
        schema=LZ_SCHEMA,
        db=LZ_DB
    )

    if load_control_table_status['status'] == False:
        raise Exception(f"Failed to update ControlTable: {load_control_table_status['message']}")
    
    logger.info(f'Processed all entities and updated incremental value.')


if __name__ == '__main__':
    main()
