/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    

    {{ config(
            materialized='incremental',
            incremental_strategy='insert_overwrite',
            alias='SUPPL_APPLICABLE_CATEGORY_DESCR',
            unique_key=[],
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        JSONFIELD:"APPLICABLE_CATEGORY_ID"::NUMBER AS APPLICABLE_CATEGORY_ID, 
 	 	JSONFIELD:"DESCR"::STRING AS DESCR,
        _FILEDATE,
		_FILENAME
        FROM {{ source('SUPPLIER', 'SUPPL_APPLICABLE_CATEGORY_DESCR') }} AS SUPPL_APPLICABLE_CATEGORY_DESCR
        WHERE _FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('SUPPLIER', 'SUPPL_APPLICABLE_CATEGORY_DESCR') }})
    ),
    transform_data as (
        SELECT
        APPLICABLE_CATEGORY_ID, 
 	 	DESCR,
        _FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
        FROM source_data
    ),
    type_data as (
        SELECT
        CAST(APPLICABLE_CATEGORY_ID AS NUMBER(38,0)) AS APPLICABLE_CATEGORY_ID, 
 	 	CAST(DESCR AS VARCHAR(16777216)) AS DESCR,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
        CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
        FROM transform_data
    )
    SELECT * FROM type_data