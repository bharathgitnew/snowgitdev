/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    

    {{ config(
            materialized='incremental',
            incremental_strategy='insert_overwrite',
            alias='ORACLE_ACCOUNT_MAP',
            tags=["finance"],
            unique_key=[],
            transient=false    
) }} 
    
    with source_data as (
        SELECT
            BASE_GL_TYPE, 
            FINANCIAL_ACCOUNT_TYPE, 
            SENSITIVE_INDICATOR, 
            FINANCIAL_STATUTORY_CATEGORY, 
            SAP_CODE, 
            SAP_ACCT_DESCRIPTION, 
            ORACLE_CODE, 
            ORACLE_GL_ALIAS, 
            ORACLE_GL_PARENT, 
            _FILEDATE,
		    _FILENAME
        FROM {{ ref('ODS__SHAREPOINT__ORACLE_GL_ACCOUNT') }} AS ORACLE_ACCOUNT_MAP
        
    ),
    transform_data as (
        SELECT
        _FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        BASE_GL_TYPE, 
 	 	FINANCIAL_ACCOUNT_TYPE, 
        CASE
            WHEN LEFT(SAP_CODE, 1) IN ('6', '7')
                THEN 'true'
            ELSE 'false'
        END AS SECURITY_IS_EXPENSE,
 	 	SENSITIVE_INDICATOR,
        CASE
            WHEN LEFT(BASE_GL_TYPE, 7) ILIKE 'Expense' THEN 'true'
            ELSE 'false'
        END AS FOR_EXPENSE_REPORTING,
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
            CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
            CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
            BASE_GL_TYPE, 
            FINANCIAL_ACCOUNT_TYPE, 
            SECURITY_IS_EXPENSE, 
            SENSITIVE_INDICATOR,
            FOR_EXPENSE_REPORTING,
            FINANCIAL_STATUTORY_CATEGORY, 
            SAP_CODE, 
            SAP_ACCT_DESCRIPTION, 
            ORACLE_CODE, 
            ORACLE_GL_ALIAS, 
            ORACLE_GL_PARENT
        FROM transform_data
    )
    SELECT * FROM type_data