/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    

    {{ config(
            materialized='tel_incremental',
            incremental_strategy='insert_overwrite',
            alias='SUPPL_BUSINESS_PARTNER',
            unique_key=[],
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        BUSINESS_PARTNER_ID, 
 	 	NAME, 
 	 	BIS_CUSTOMER_CODE, 
 	 	TEL_REGION,
        _FILEDATE,
		_FILENAME
        FROM {{ ref('BRONZE__TMEA_QUALITY__SUPPLIER_SUPPL_BUSINESS_PARTNER') }} AS SUPPL_BUSINESS_PARTNER
        
    ),
    transform_data as (
        SELECT
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        _FILEDATE,
		_FILENAME,
        BUSINESS_PARTNER_ID, 
 	 	NAME, 
 	 	BIS_CUSTOMER_CODE, 
 	 	TEL_REGION
        FROM source_data
    ),
    type_data as (
        SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
        CAST(BUSINESS_PARTNER_ID AS NUMBER(38,0)) AS BUSINESS_PARTNER_ID, 
 	 	CAST(NAME AS VARCHAR(16777216)) AS NAME, 
 	 	CAST(BIS_CUSTOMER_CODE AS VARCHAR(16777216)) AS BIS_CUSTOMER_CODE, 
 	 	CAST(TEL_REGION AS VARCHAR(16777216)) AS TEL_REGION
        FROM transform_data
    )
    SELECT * FROM type_data