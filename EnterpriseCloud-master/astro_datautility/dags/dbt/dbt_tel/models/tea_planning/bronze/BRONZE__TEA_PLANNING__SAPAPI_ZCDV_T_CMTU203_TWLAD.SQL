/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAPAPI_ZCDV_T_CMTU203_TWLAD',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:Mandt::STRING AS MANDT,
		JSONFIELD:Werks::STRING AS WERKS,
		JSONFIELD:Lgort::STRING AS LGORT,
		JSONFIELD:Lfdnr::STRING AS LFDNR,
		JSONFIELD:Adrnr::STRING AS ADRNR
    FROM {{ source('SAPAPI','ZCDV_T_CMTU203_TWLAD') }}
    where _FILEDATE = (select ifnull(try_to_timestamp_ntz(max(MAX_FILE_DATE), 'YYYY-MM-DD_hh_mi_ss_ff6'), '1970-01-01') from {{ source('SAPAPI', 'CONTROLTABLE') }} where TABLE_NAME = 'ZCDV_T_CMTU203')

	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		MANDT as MANDT,
		WERKS as WERKS,
		LGORT as LGORT,
		LFDNR as LFDNR,
		ADRNR as ADRNR
    FROM source_data 
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        _AUDIT_LOG_ID,
        _ROW_HASH,
		MANDT,
		WERKS,
		LGORT,
		LFDNR,
		ADRNR
    FROM transform_data 
)

	select * from type_data