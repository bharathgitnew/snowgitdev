/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    

    {{ config(
            materialized='incremental',
            incremental_strategy='insert_overwrite',
            alias='SUPPL_APPLICABLE_CATEGORY',
            unique_key=[],
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        REQUEST_ID, 
 	 	APPLICABLE_CATEGORY_ID,
        _FILEDATE,
		_FILENAME
        FROM {{ ref('ODS__SUPPLIER__SUPPL_APPLICABLE_CATEGORY') }} AS SUPPL_APPLICABLE_CATEGORY
        
    ),
    transform_data as (
        SELECT
        REQUEST_ID, 
 	 	APPLICABLE_CATEGORY_ID,
        _FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
        FROM source_data
    ),
    type_data as (
        SELECT
        CAST(REQUEST_ID AS NUMBER(38,0)) AS REQUEST_ID, 
 	 	CAST(APPLICABLE_CATEGORY_ID AS NUMBER(38,0)) AS APPLICABLE_CATEGORY_ID,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
        CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
        FROM transform_data
    )
    SELECT * FROM type_data