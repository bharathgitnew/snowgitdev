/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='ZCDV_T_CMTU018_MAKT',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		JSONFIELD:Mandt::STRING as MANDT,
		JSONFIELD:Matnr::STRING as MATNR,
		JSONFIELD:Spras::STRING as SPRAS,
		JSONFIELD:Maktx::STRING as MAKTX,
		JSONFIELD:Maktg::STRING as MAKTG
	from {{ source('SAPAPI','ZCDV_T_CMTU018_MAKT') }}
    where _FILEDATE = (select ifnull(try_to_timestamp_ntz(max(MAX_FILE_DATE), 'YYYY-MM-DD_hh_mi_ss_ff6'), '1970-01-01') from {{ source('SAPAPI', 'CONTROLTABLE') }} where TABLE_NAME = 'ZCDV_T_CMTU018')

	),
	
	transform_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
		"MANDT", 
 	 	"MATNR", 
 	 	"SPRAS", 
 	 	"MAKTX", 
 	 	"MAKTG"
	from source_data
	),
	
	type_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		AUDIT_LOG_ID,
        _ROW_HASH,
		"MANDT", 
 	 	"MATNR", 
 	 	"SPRAS", 
 	 	"MAKTX", 
 	 	"MAKTG"
	from transform_data
	)

	select * from type_data