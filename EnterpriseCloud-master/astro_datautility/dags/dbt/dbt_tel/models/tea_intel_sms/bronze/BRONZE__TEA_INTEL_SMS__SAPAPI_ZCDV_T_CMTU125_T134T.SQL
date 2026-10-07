/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAPAPI_ZCDV_T_CMTU125_T134T',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as ( 
     SELECT DISTINCT 
        _FILEDATE,
        _FILENAME,
		JSONFIELD:MANDT::STRING AS MANDT, --this value is always null even in SAPAPI.
		JSONFIELD:SPRAS::STRING AS SPRAS,
		JSONFIELD:MTART::STRING AS MTART,
		JSONFIELD:MTBEZ::STRING AS MTBEZ
    FROM {{ source('SAPH','SAP_MMM_EV_T134T') }}
	 WHERE _FILEDATE::STRING = (
        SELECT MAX(RUN_TIME)::STRING
        FROM {{ source('SAPH', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'SAP_MMM_EV_T134T'
        )
	and SPRAS = 'EN'
	QUALIFY ROW_NUMBER() OVER ( PARTITION BY MTART, SPRAS ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		MANDT as MANDT,
		SPRAS as SPRAS,
		MTART as MTART,
		MTBEZ as MTBEZ
    FROM source_data 
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        _AUDIT_LOG_ID,
        _ROW_HASH,
		MANDT,
		SPRAS,
		MTART,
		MTBEZ
    FROM transform_data 
)

	select * from type_data