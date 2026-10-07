/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAPAPI_ZCDV_T_CMTU160_TVAUT',
    	  unique_key = [''],
    	  tags=["finance", "insert_overwrite_tea_logistics"],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILENAME,
        _FILEDATE,
		JSONFIELD:MANDT::STRING AS MANDT,
		JSONFIELD:SPRAS::STRING AS SPRAS,
		JSONFIELD:AUGRU::STRING AS AUGRU,
		JSONFIELD:BEZEI::STRING AS BEZEI
    from {{ source('SAPH','SAP_SDM_EV_TVAUT') }}
    WHERE _FILEDATE::STRING = (
        SELECT MAX(RUN_TIME)::STRING
        FROM {{ source('SAPH', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'SAP_SDM_EV_TVAUT'
        )
	and SPRAS='EN'
QUALIFY ROW_NUMBER() OVER ( PARTITION BY AUGRU, SPRAS ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
),
	
	transform_data as (
    SELECT
        _FILENAME AS _FILENAME,
        _FILEDATE AS _FILEDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		SPRAS as SPRAS,
		AUGRU as AUGRU,
		BEZEI as BEZEI
    FROM source_data 
),

type_data as (
    SELECT
        _FILENAME,
        _FILEDATE,
        _AUDIT_LOG_ID,
        _ROW_HASH,
		SPRAS,
		AUGRU,
		BEZEI
    FROM transform_data 
)
	select * from type_data