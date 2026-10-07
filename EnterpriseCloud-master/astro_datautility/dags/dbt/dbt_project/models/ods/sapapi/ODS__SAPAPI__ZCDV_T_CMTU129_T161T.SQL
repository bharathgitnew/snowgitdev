/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='ZCDV_T_CMTU129_T161T',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT DISTINCT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:MANDT::STRING AS MANDT, --this value is always null even in SAPAPI.
		JSONFIELD:SPRAS::STRING AS SPRAS,
		JSONFIELD:BSART::STRING AS BSART,
		JSONFIELD:BSTYP::STRING AS BSTYP,
		JSONFIELD:BATXT::STRING AS BATXT
    FROM {{ source('SAPH','SAP_MMM_EV_T161T') }}
    	WHERE _FILEDATE::STRING = (
        SELECT MAX(RUN_TIME)::STRING
        FROM {{ source('SAPH', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'SAP_MMM_EV_T161T'
        )
	and SPRAS ='EN'
	QUALIFY ROW_NUMBER() OVER ( PARTITION BY BSART, BSTYP, SPRAS ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		MANDT as MANDT,
		SPRAS as SPRAS,
		BSART as BSART,
		BSTYP as BSTYP,
		BATXT as BATXT
    FROM source_data 
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        AUDIT_LOG_ID,
        _ROW_HASH,
		MANDT,
		SPRAS,
		BSART,
		BSTYP,
		BATXT
    FROM transform_data 
)

	select * from type_data