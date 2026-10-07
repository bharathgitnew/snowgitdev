/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='TJ04',
    	  unique_key = [''],
    	  tags=["manual_load"],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		"OBTYP", 
 	 	"ISTAT", 
 	 	"INIST", 
 	 	"LINEP", 
 	 	"STATP"
	
	from {{ source('SAPAPI','TJ04') }}
	WHERE REGEXP_SUBSTR(_FILENAME,'\\d{14}') = (SELECT MAX(REGEXP_SUBSTR(_filename,'\\d{14}')) from {{ source('SAPAPI', 'TJ04') }})

	),
	
	transform_data as (
	SELECT 
		_FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
		"OBTYP", 
 	 	"ISTAT", 
 	 	"INIST", 
 	 	"LINEP", 
 	 	"STATP"
	from source_data
	),
	
	type_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		AUDIT_LOG_ID,
        _ROW_HASH,
		"OBTYP", 
 	 	"ISTAT", 
 	 	"INIST", 
 	 	"LINEP", 
 	 	"STATP"
	from transform_data
	)

	select * from type_data