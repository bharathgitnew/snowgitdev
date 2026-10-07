/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    

    {{ config(
            materialized='tel_incremental',
            incremental_strategy='insert_overwrite',
            alias='SUPPLIER_SUPPL_ROLE_DESCR',
            unique_key=[],
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        JSONFIELD:"DESCR"::STRING AS DESCR, 
 	 	JSONFIELD:"ROLEID"::NUMBER AS ROLEID,
        _FILEDATE,
		_FILENAME
        FROM {{ source('SUPPLIER', 'SUPPL_ROLE_DESCR') }} AS SUPPL_ROLE_DESCR
        WHERE _FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('SUPPLIER', 'SUPPL_ROLE_DESCR') }})
    ),
    transform_data as (
        SELECT
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        _FILEDATE,
		_FILENAME,
        DESCR, 
 	 	ROLEID
        FROM source_data
    ),
    type_data as (
        SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
        CAST(DESCR AS VARCHAR(16777216)) AS DESCR, 
 	 	CAST(ROLEID AS NUMBER(38,0)) AS ROLEID
        FROM transform_data
    )
    SELECT * FROM type_data