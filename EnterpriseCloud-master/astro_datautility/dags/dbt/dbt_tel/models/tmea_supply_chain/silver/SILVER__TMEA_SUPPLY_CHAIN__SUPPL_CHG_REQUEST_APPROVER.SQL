/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    
    {{ config(
            materialized='tel_incremental',
            incremental_strategy='insert_overwrite',
            alias='SUPPL_CHG_REQUEST_APPROVER',
            unique_key=[],
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        REQUEST_ID, 
 	 	USERID, 
 	 	ROLEID,
        _FILEDATE,
		_FILENAME
        FROM {{ ref('BRONZE__TMEA_SUPPLY_CHAIN__SUPPLIER_SUPPL_CHG_REQUEST_APPROVER') }} AS SUPPL_CHG_REQUEST_APPROVER
        
    ),
    transform_data as (
        SELECT
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        _FILEDATE,
		_FILENAME,
        REQUEST_ID, 
 	 	USERID, 
 	 	ROLEID
        FROM source_data
    ),
    type_data as (
        SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
        CAST(REQUEST_ID AS NUMBER(38,0)) AS REQUEST_ID, 
 	 	CAST(USERID AS NUMBER(38,0)) AS USERID, 
 	 	CAST(ROLEID AS NUMBER(38,0)) AS ROLEID
        FROM transform_data
    )
    SELECT * FROM type_data