{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='ORACLE_SEGMENT'
) }}


with source_data AS 
(
    SELECT
    _FILENAME,
    _FILEDATE,
    jsonfield:fields.Title::STRING as ORACLE_CODE,
    jsonfield:fields.ORACLE_NAME_x0020_::STRING as ORACLE_NAME,
    jsonfield:fields.SAP_CODE_x0020_::STRING as SAP_CODE,
    jsonfield:fields.SAP_NAME::STRING as SAP_NAME,
    jsonfield:fields.Created::STRING as CREATED,
    jsonfield:fields.Modified::STRING as MODIFIED,
    DataItems.value:email::STRING AS CREATEDBY,
    DataItems1.value:email::STRING AS MODIFIEDBY  
    FROM {{source('SHAREPOINT', 'SEGMENT')}},
    LATERAL FLATTEN (input => JsonField:createdBy) DataItems,
    LATERAL FLATTEN (input => JsonField:lastModifiedBy) DataItems1 
    WHERE _FILEDATE = (SELECT MAX(_FILEDATE) from {{ source('SHAREPOINT','SEGMENT') }})
)

,transform_data AS
(
    SELECT 
        _FILENAME,
        _FILEDATE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        ORACLE_CODE,
        ORACLE_NAME,
        SAP_CODE,
        SAP_NAME,
        CREATED,
        MODIFIED,
        CREATEDBY,
        MODIFIEDBY
    FROM source_data
)

,type_data AS 
(
    SELECT 
        _FILENAME,
        _FILEDATE,
        CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        ORACLE_CODE,
        ORACLE_NAME,
        SAP_CODE,
        SAP_NAME,
        CREATED,
        MODIFIED,
        CREATEDBY,
        MODIFIEDBY
    FROM transform_data
)

SELECT * FROM type_data