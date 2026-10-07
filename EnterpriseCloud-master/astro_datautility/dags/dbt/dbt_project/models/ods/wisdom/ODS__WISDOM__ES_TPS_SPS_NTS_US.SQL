{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='ES_TPS_SPS_NTS_US'
) }}

with source_data as
(
    SELECT 
        JSONFIELD:BU_NAME::String as BU_NAME,
        JSONFIELD:CATEGORY::String as CATEGORY,
        JSONFIELD:DOC_NO::String as DOC_NO,
        JSONFIELD:DOC_TITLE::String as DOC_TITLE,
        JSONFIELD:EMP_NO::String as EMP_NO,
        JSONFIELD:ISSUE_DT::String as ISSUE_DT,
        JSONFIELD:LANG::String as LANG,
        JSONFIELD:MODEL::String as MODEL,
        JSONFIELD:NAME::String as NAME,
        JSONFIELD:PRIORITY::String as PRIORITY,
        JSONFIELD:READ_DT::String as READ_DT,
        _filedate as _FILEDATE
    FROM {{ source('WISDOM','ES_TPS_SPS_NTS_US') }}
    
    WHERE _FILEDATE = (
    SELECT MAX(RUN_TIME)
    FROM {{ source('WISDOM', 'CONTROLTABLE') }}
    WHERE TABLE_NAME = 'V_ES_TPS_SPS_NTS_US'
)
    
    ),

transform_data as 
(
    SELECT
        _FILEDATE as _FILEDATE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
            BU_NAME as BU_NAME,
        CATEGORY as CATEGORY,
        DOC_NO as DOC_NO,
        DOC_TITLE as DOC_TITLE,
        EMP_NO as EMP_NO,
        ISSUE_DT::TIMESTAMP_NTZ as ISSUE_DT,
        LANG as LANG,
        MODEL as MODEL,
        NAME as NAME,
        PRIORITY as PRIORITY,
        READ_DT::TIMESTAMP_NTZ as READ_DT
    FROM source_data 
),
type_data as 
(
    SELECT
        _FILEDATE,
        AUDIT_LOG_ID,
        _ROW_HASH,
        BU_NAME,
        CATEGORY,
        DOC_NO,
        DOC_TITLE,
        EMP_NO,
        ISSUE_DT,
        LANG,
        MODEL,
        NAME,
        PRIORITY,
        READ_DT
    FROM transform_data 
)
select * from type_data