/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='ZCDV_T_CMTU239_T015W',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:Mandt::STRING AS MANDT,
		JSONFIELD:BANKS::STRING AS BANKS,
		JSONFIELD:ZLSCH::STRING AS ZLSCH,
		JSONFIELD:DTAWS::STRING AS DTAWS,
		JSONFIELD:DTWS1::STRING AS DTWS1,
		JSONFIELD:DTWS2::STRING AS DTWS2,
		JSONFIELD:DTWS3::STRING AS DTWS3,
		JSONFIELD:DTWS4::STRING AS DTWS4,
		JSONFIELD:DTZUS::STRING AS DTZUS,
		JSONFIELD:DTKVS::STRING AS DTKVS,
		JSONFIELD:DTKZA::STRING AS DTKZA,
		JSONFIELD:EDIZA::STRING AS EDIZA,
		JSONFIELD:EDIME::STRING AS EDIME,
		JSONFIELD:DTWSC::STRING AS DTWSC,
		JSONFIELD:DTURG::STRING AS DTURG
    FROM {{ source('SAPAPI','ZCDV_T_CMTU239_T015W') }}
    where _FILEDATE = (select ifnull(try_to_timestamp_ntz(max(MAX_FILE_DATE), 'YYYY-MM-DD_hh_mi_ss_ff6'), '1970-01-01') from {{ source('SAPAPI', 'CONTROLTABLE') }} where TABLE_NAME = 'ZCDV_T_CMTU239')

	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		BANKS as BANKS,
		DTAWS as DTAWS,
		ZLSCH as ZLSCH,
		MANDT as MANDT,
		DTKVS as DTKVS,
		DTKZA as DTKZA,
		DTURG as DTURG,
		DTWS1 as DTWS1,
		DTWS2 as DTWS2,
		DTWS3 as DTWS3,
		DTWS4 as DTWS4,
		DTWSC as DTWSC,
		DTZUS as DTZUS,
		EDIME as EDIME,
		EDIZA as EDIZA
    FROM source_data 
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        AUDIT_LOG_ID,
        _ROW_HASH,
		BANKS,
		DTAWS,
		ZLSCH,
		MANDT,
		DTKVS,
		DTKZA,
		DTURG,
		DTWS1,
		DTWS2,
		DTWS3,
		DTWS4,
		DTWSC,
		DTZUS,
		EDIME,
		EDIZA
    FROM transform_data 
)

	select * from type_data