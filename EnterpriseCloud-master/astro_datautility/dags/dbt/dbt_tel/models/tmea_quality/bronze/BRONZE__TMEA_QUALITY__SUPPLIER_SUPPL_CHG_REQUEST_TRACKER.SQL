/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    

    {{ config(
            materialized='tel_incremental',
            incremental_strategy='insert_overwrite',
            alias='SUPPLIER_SUPPL_CHG_REQUEST_TRACKER',
            unique_key=[],
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        JSONFIELD:"SUPPL_CHG_REQUEST_TRACKER_ID"::NUMBER AS SUPPL_CHG_REQUEST_TRACKER_ID, 
 	 	JSONFIELD:"ACTION_ID"::NUMBER AS ACTION_ID, 
 	 	JSONFIELD:"REQUEST_ID"::NUMBER AS REQUEST_ID, 
 	 	REGEXP_REPLACE(JSONFIELD:"ACTION_DT", '\/Date\\(|\\)\/', '')::TIMESTAMP AS ACTION_DT, 
 	 	JSONFIELD:"USERID"::NUMBER AS USERID,
        _FILEDATE,
		_FILENAME
        FROM {{ source('SUPPLIER', 'SUPPL_CHG_REQUEST_TRACKER') }} AS SUPPL_CHG_REQUEST_TRACKER
        WHERE _FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('SUPPLIER', 'SUPPL_CHG_REQUEST_TRACKER') }})
    ),
    transform_data as (
        SELECT
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        _FILEDATE,
		_FILENAME,
        SUPPL_CHG_REQUEST_TRACKER_ID, 
 	 	ACTION_ID, 
 	 	REQUEST_ID, 
 	 	ACTION_DT, 
 	 	USERID
        FROM source_data
    ),
    type_data as (
        SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
        CAST(SUPPL_CHG_REQUEST_TRACKER_ID AS NUMBER(38,0)) AS SUPPL_CHG_REQUEST_TRACKER_ID, 
 	 	CAST(ACTION_ID AS NUMBER(38,0)) AS ACTION_ID, 
 	 	CAST(REQUEST_ID AS NUMBER(38,0)) AS REQUEST_ID, 
 	 	CAST(ACTION_DT AS TIMESTAMP_NTZ(9)) AS ACTION_DT, 
 	 	CAST(USERID AS NUMBER(38,0)) AS USERID
        FROM transform_data
    )
    SELECT * FROM type_data