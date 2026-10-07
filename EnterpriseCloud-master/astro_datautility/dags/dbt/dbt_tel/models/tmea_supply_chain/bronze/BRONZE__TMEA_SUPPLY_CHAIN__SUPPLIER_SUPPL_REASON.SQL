/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    
    {{ config(
            materialized='tel_incremental',
            incremental_strategy='insert_overwrite',
            alias='SUPPLIER_SUPPL_REASON',
            unique_key=[],
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        JSONFIELD:"REQUEST_ID"::NUMBER AS REQUEST_ID, 
 	 	JSONFIELD:"REASON_ID"::NUMBER AS REASON_ID,
        _FILEDATE,
		_FILENAME
        FROM {{ source('SUPPLIER', 'SUPPL_REASON') }} AS SUPPL_REASON
        WHERE _FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('SUPPLIER', 'SUPPL_REASON') }})
    ),
    transform_data as (
        SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        _FILEDATE,
        _FILENAME,
        REQUEST_ID,
        REASON_ID
        FROM source_data
    ),
    type_data as (
        SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
        CAST(REQUEST_ID AS NUMBER(38,0)) AS REQUEST_ID,
        CAST(REASON_ID AS NUMBER(38,0)) AS REASON_ID
        FROM transform_data
    )
    SELECT * FROM type_data