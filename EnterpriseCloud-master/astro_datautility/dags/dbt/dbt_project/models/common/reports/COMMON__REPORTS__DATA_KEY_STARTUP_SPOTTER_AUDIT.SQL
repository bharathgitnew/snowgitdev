/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    

    {{ config(
            materialized='incremental',
            incremental_strategy='insert_overwrite',
            alias='DATA_KEY_STARTUP_SPOTTER_AUDIT',
            unique_key=[],
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        INDEX, 
 	 	QUESTION,
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE
        FROM {{ ref('ODS__FILE__DATA_KEY_STARTUP_SPOTTER_AUDIT') }} AS DATA_KEY_STARTUP_SPOTTER_AUDIT
        
    ),
    transform_data as (
        SELECT
        INDEX, 
 	 	QUESTION,
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
        FROM source_data
    ),
    type_data as (
        SELECT
        CAST(INDEX AS VARCHAR(16777216)) AS INDEX, 
 	 	CAST(QUESTION AS VARCHAR(16777216)) AS QUESTION,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
        FROM transform_data
    )
    SELECT * FROM type_data