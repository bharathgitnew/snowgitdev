/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    
    {{ config(
            materialized='tel_incremental',
            incremental_strategy='insert_overwrite',
            alias='SUPPLIER_SUPPL_FACTORY',
            unique_key=[],
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        JSONFIELD:"ID"::NUMBER AS ID, 
 	 	JSONFIELD:"DESCR"::STRING AS DESCR,
        _FILEDATE,
		_FILENAME
        FROM {{ source('SUPPLIER', 'SUPPL_FACTORY') }} AS SUPPL_FACTORY
        WHERE _FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('SUPPLIER', 'SUPPL_FACTORY') }})
    ),
    transform_data as (
        SELECT
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        _FILEDATE,
		_FILENAME,
        ID, 
 	 	DESCR
        FROM source_data
    ),
    type_data as (
        SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
        CAST(ID AS NUMBER(38,0)) AS ID, 
 	 	CAST(DESCR AS VARCHAR(16777216)) AS DESCR
        FROM transform_data
    )
    SELECT * FROM type_data