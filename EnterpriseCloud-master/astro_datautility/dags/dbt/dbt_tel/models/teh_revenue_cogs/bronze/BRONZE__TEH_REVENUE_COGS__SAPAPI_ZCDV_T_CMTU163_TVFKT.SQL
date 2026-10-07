/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAPAPI_ZCDV_T_CMTU163_TVFKT',
    	  unique_key = [''],
    	  tags=["finance"],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:MANDT::STRING AS MANDT,
		JSONFIELD:SPRAS::STRING AS SPRAS,
		JSONFIELD:FKART::STRING AS FKART,
		JSONFIELD:VTEXT::STRING AS VTEXT
    from {{ source('SAPH','SAP_SDM_EV_TVFKT') }}
	WHERE _FILEDATE::STRING = (
        SELECT MAX(RUN_TIME)::STRING
        FROM {{ source('SAPH', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'SAP_SDM_EV_TVFKT'
        )
	and SPRAS = 'EN'
	QUALIFY ROW_NUMBER() OVER ( PARTITION BY FKART, SPRAS ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		COALESCE(SPRAS, '') as SPRAS,
		COALESCE(FKART, '') as FKART,
		COALESCE(VTEXT, '') as VTEXT
    FROM source_data 
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        _AUDIT_LOG_ID,
        _ROW_HASH,
		SPRAS,
		FKART,
		VTEXT
    FROM transform_data 
)

	select * from type_data