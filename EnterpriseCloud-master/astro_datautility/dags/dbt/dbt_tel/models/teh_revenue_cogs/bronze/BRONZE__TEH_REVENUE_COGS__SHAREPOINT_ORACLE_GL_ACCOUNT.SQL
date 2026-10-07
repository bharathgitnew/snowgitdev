{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SHAREPOINT_ORACLE_GL_ACCOUNT',
    transient=false
) }}

with source_data AS 
(
    SELECT
    _FILENAME,
    _FILEDATE,
    jsonfield:fields.Title::STRING as BASE_GL_TYPE,
    jsonfield:fields.FINANCIAL_ACCOUNT_TYPE::STRING as FINANCIAL_ACCOUNT_TYPE,
    jsonfield:fields.SENSITIVE_INDICATOR::STRING as SENSITIVE_INDICATOR,
    jsonfield:fields.FINANCIAL_STATUTORY_CATEGORY::STRING as FINANCIAL_STATUTORY_CATEGORY,
    jsonfield:fields.SAP_CODE::STRING as SAP_CODE,
    jsonfield:fields.SAP_ACCT_DESCRIPTION::STRING as SAP_ACCT_DESCRIPTION,
    jsonfield:fields.ORACLE_CODE::STRING as ORACLE_CODE,
    jsonfield:fields.ORACLE_GL_ALIAS::STRING as ORACLE_GL_ALIAS,
    jsonfield:fields.ORACLE_GL_PARENT::STRING as ORACLE_GL_PARENT,
    jsonfield:fields.Created::STRING as CREATED,
    jsonfield:fields.Modified::STRING as MODIFIED,
    DataItems.value:email::STRING AS CREATEDBY,
    DataItems1.value:email::STRING AS MODIFIEDBY  
    FROM {{source('SHAREPOINT', 'GL_ACCOUNT')}},
    LATERAL FLATTEN (input => JsonField:createdBy) DataItems,
    LATERAL FLATTEN (input => JsonField:lastModifiedBy) DataItems1 
    WHERE _FILEDATE = (SELECT MAX(_FILEDATE) from {{ source('SHAREPOINT','GL_ACCOUNT') }})
)

,transform_data AS
(
    SELECT 
        _FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        BASE_GL_TYPE,
        FINANCIAL_ACCOUNT_TYPE,
        SENSITIVE_INDICATOR,
        FINANCIAL_STATUTORY_CATEGORY,
        SAP_CODE,
        SAP_ACCT_DESCRIPTION,
        ORACLE_CODE,
        ORACLE_GL_ALIAS,
        ORACLE_GL_PARENT,
        CREATED,
        MODIFIED,
        CREATEDBY,
        MODIFIEDBY
    FROM source_data
)

,type_data AS 
(
    SELECT 
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		cast(_FILENAME as varchar(128)) as _FILENAME,
		cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        BASE_GL_TYPE,
        FINANCIAL_ACCOUNT_TYPE,
        SENSITIVE_INDICATOR,
        FINANCIAL_STATUTORY_CATEGORY,
        SAP_CODE,
        SAP_ACCT_DESCRIPTION,
        ORACLE_CODE,
        ORACLE_GL_ALIAS,
        ORACLE_GL_PARENT,
        CREATED,
        MODIFIED,
        CREATEDBY,
        MODIFIEDBY
    FROM transform_data
)

SELECT * FROM type_data