/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    

    {{ config(
            materialized='incremental',
            incremental_strategy='insert_overwrite',
            alias='ORACLE_ACCOUNT_MAP',
            unique_key=[],
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE,
        BASE_GL_TYPE, 
 	 	FINANCIAL_ACCOUNT_TYPE, 
 	 	SENSITIVE_INDICATOR, 
 	 	FINANCIAL_STATUTORY_CATEGORY, 
 	 	SAP_CODE, 
 	 	SAP_ACCT_DESCRIPTION, 
 	 	ORACLE_CODE, 
 	 	ORACLE_GL_ALIAS, 
 	 	ORACLE_GL_PARENT

        FROM {{ source('FILE', 'ORACLE_ACCOUNT_MAP') }} AS ORACLE_ACCOUNT_MAP
        WHERE _UPLOADDATE = (SELECT MAX(_UPLOADDATE) FROM {{ source('FILE', 'ORACLE_ACCOUNT_MAP') }})
    ),
    transform_data as (
        SELECT
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        BASE_GL_TYPE, 
 	 	FINANCIAL_ACCOUNT_TYPE, 
 	 	SENSITIVE_INDICATOR, 
 	 	FINANCIAL_STATUTORY_CATEGORY, 
 	 	SAP_CODE, 
 	 	SAP_ACCT_DESCRIPTION, 
 	 	ORACLE_CODE, 
 	 	ORACLE_GL_ALIAS, 
 	 	ORACLE_GL_PARENT

        FROM source_data
    ),
    type_data as (
        SELECT
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        BASE_GL_TYPE, 
 	 	FINANCIAL_ACCOUNT_TYPE, 
 	 	SENSITIVE_INDICATOR, 
 	 	FINANCIAL_STATUTORY_CATEGORY, 
 	 	SAP_CODE, 
 	 	SAP_ACCT_DESCRIPTION, 
 	 	ORACLE_CODE, 
 	 	ORACLE_GL_ALIAS, 
 	 	ORACLE_GL_PARENT
    
        FROM transform_data
    )
    SELECT * FROM type_data