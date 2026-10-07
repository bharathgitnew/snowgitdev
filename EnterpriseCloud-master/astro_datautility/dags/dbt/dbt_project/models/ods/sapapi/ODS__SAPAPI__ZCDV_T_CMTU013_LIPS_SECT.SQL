/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='ZCDV_T_CMTU013_LIPS_SECT',
    	  unique_key = [''],
    	  tags=["finance"],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:Vbeln::STRING AS VBELN,
		JSONFIELD:Posnr::STRING AS POSNR,
		JSONFIELD:Gbsta::STRING AS GBSTA
    FROM {{ source('SAPAPI','ZCDV_T_CMTU013_LIPS_SECT') }}
    where _FILEDATE = (select ifnull(try_to_timestamp_ntz(max(MAX_FILE_DATE), 'YYYY-MM-DD_hh_mi_ss_ff6'), '1970-01-01') from {{ source('SAPAPI', 'CONTROLTABLE') }} where TABLE_NAME = 'ZCDV_T_CMTU013_SECT')
	QUALIFY (ROW_NUMBER() OVER (PARTITION BY VBELN,POSNR ORDER BY _FILEDATE DESC,_UPLOADDATE DESC )) = 1

	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		VBELN as VBELN,
		POSNR as POSNR,
		GBSTA as GBSTA
    FROM source_data 
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        AUDIT_LOG_ID,
        _ROW_HASH,
		VBELN,
		POSNR,
		GBSTA
    FROM transform_data 
)

	select * from type_data