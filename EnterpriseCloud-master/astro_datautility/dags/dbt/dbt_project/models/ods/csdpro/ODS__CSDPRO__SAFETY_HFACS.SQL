/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    

    {{ config(
            materialized='incremental',
            incremental_strategy='insert_overwrite',
            alias='SAFETY_HFACS',
            unique_key=[],
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        _FILEDATE,
		_FILENAME,
        JSONFIELD:"investigation_id"::NUMBER AS investigation_id, 
 	 	JSONFIELD:"hfacs_type_description"::STRING AS hfacs_type_description, 
 	 	JSONFIELD:"hfacs_description"::STRING AS hfacs_description
        FROM {{ source('CSDPRO', 'SAFETY_HFACS') }} AS SAFETY_HFACS
        WHERE _FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('CSDPRO', 'SAFETY_HFACS') }})
    ),
    transform_data as (
        SELECT
        _FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        INVESTIGATION_ID, 
 	 	HFACS_TYPE_DESCRIPTION, 
 	 	HFACS_DESCRIPTION
        FROM source_data
    ),
    type_data as (
        SELECT
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(INVESTIGATION_ID AS NUMBER(38,0)) AS INVESTIGATION_ID, 
 	 	HFACS_TYPE_DESCRIPTION, 
 	 	HFACS_DESCRIPTION
        FROM transform_data
    )
    SELECT * FROM type_data