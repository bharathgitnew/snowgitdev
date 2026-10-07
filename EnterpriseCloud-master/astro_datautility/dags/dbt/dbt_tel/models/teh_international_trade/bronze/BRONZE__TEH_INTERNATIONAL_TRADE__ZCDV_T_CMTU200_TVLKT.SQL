/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='ZCDV_T_CMTU200_TVLKT',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:Mandt::STRING AS MANDT,
		JSONFIELD:Spras::STRING AS SPRAS,
		JSONFIELD:Lfart::STRING AS LFART,
		JSONFIELD:Vtext::STRING AS VTEXT
    FROM {{ source('SAPAPI','ZCDV_T_CMTU200_TVLKT') }}
    where _FILEDATE = (select ifnull(try_to_timestamp_ntz(max(MAX_FILE_DATE), 'YYYY-MM-DD_hh_mi_ss_ff6'), '1970-01-01') from {{ source('SAPAPI', 'CONTROLTABLE') }} where TABLE_NAME = 'ZCDV_T_CMTU200')

	),
	
	transform_data as (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		_FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
		MANDT as MANDT,
		SPRAS as SPRAS,
		LFART as LFART,
		VTEXT as VTEXT
    FROM source_data 
),

type_data as (
    SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
		MANDT,
		SPRAS,
		LFART,
		VTEXT
    FROM transform_data 
)

	select * from type_data