/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='ZCDV_T_CMTU010_VBAP_SECT',
    	  tags=["finance_gmx"],
    	  unique_key = [''],
    	  transient=false	
) }} 


	with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:item::STRING AS POSNR,
		JSONFIELD:overalldt::STRING AS GBSTA,
		JSONFIELD:sales_doc::STRING AS VBELN
    FROM {{ source('SAPAPI','ZCDV_CM0610_01_VBAP_SECT') }}	
    where _FILEDATE = (select ifnull(try_to_timestamp_ntz(max(MAX_FILE_DATE), 'YYYY-MM-DD_hh_mi_ss_ff6'), '1970-01-01') from {{ source('SAPAPI', 'CONTROLTABLE') }} where TABLE_NAME = 'ZCDV_CM0610_01_SECT')
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