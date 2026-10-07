{{ config(
        materialized='incremental'    ,
    incremental_strategy='insert_overwrite'    ,
    alias='WISDOM_SURB_PROGRESS'    
) }}

with source_data as
(
    SELECT 
        JSONFIELD:ACK_DT::STRING as ACK_DT,
        JSONFIELD:ACK_EMP_NO::STRING as ACK_EMP_NO,
        JSONFIELD:ACTUAL_COMMENT::STRING as ACTUAL_COMMENT,
        JSONFIELD:ACTUAL_END::STRING as ACTUAL_END,
        JSONFIELD:ACTUAL_START::STRING as ACTUAL_START,
        JSONFIELD:COMMENT_CTG_ID::STRING as COMMENT_CTG_ID,
        JSONFIELD:DAYS::NUMBER as DAYS,
        JSONFIELD:MAC_ID::STRING as MAC_ID,
        JSONFIELD:MASTER_ID::STRING as MASTER_ID,
        JSONFIELD:NAME::STRING as NAME,
        JSONFIELD:NAME_J::STRING as NAME_J,
        JSONFIELD:STARTUP_TYPE::STRING as STARTUP_TYPE,
        JSONFIELD:TARGET_COMMENT::STRING as TARGET_COMMENT,
        JSONFIELD:TARGET_END::STRING as TARGET_END,
        JSONFIELD:TARGET_START::STRING as TARGET_START,
        JSONFIELD:TASK_ID::STRING as TASK_ID,
        JSONFIELD:TYPE::STRING as TYPE,
        _filedate as _FILEDATE
    FROM {{ source('WISDOM','WISDOM_SURB_PROGRESS') }}
    WHERE _FILEDATE = (
    SELECT MAX(RUN_TIME)
    FROM {{ source('WISDOM', 'CONTROLTABLE') }}
    WHERE TABLE_NAME = 'WISDOM_SURB_PROGRESS'
)

),

transform_data as 
(
    SELECT
        _FILEDATE as _FILEDATE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        ACK_DT::DATE as ACK_DT,
        ACK_EMP_NO as ACK_EMP_NO,
        ACTUAL_COMMENT as ACTUAL_COMMENT,
        ACTUAL_END::DATE as ACTUAL_END,
        ACTUAL_START::DATE as ACTUAL_START,
        COMMENT_CTG_ID as COMMENT_CTG_ID,
        DAYS as DAYS,
        MAC_ID as MAC_ID,
        MASTER_ID as MASTER_ID,
        NAME as NAME,
        NAME_J as NAME_J,
        STARTUP_TYPE as STARTUP_TYPE,
        TARGET_COMMENT as TARGET_COMMENT,
        TARGET_END::DATE as TARGET_END,
        TARGET_START::DATE as TARGET_START,
        TASK_ID as TASK_ID,
        TYPE as TYPE
    FROM source_data 
),
type_data as 
(
    SELECT
        _FILEDATE,
        AUDIT_LOG_ID,
        _ROW_HASH,
        ACK_DT,
        ACK_EMP_NO,
        ACTUAL_COMMENT,
        ACTUAL_END,
        ACTUAL_START,
        COMMENT_CTG_ID,
        DAYS,
        MAC_ID,
        MASTER_ID,
        NAME,
        NAME_J,
        STARTUP_TYPE,
        TARGET_COMMENT,
        TARGET_END,
        TARGET_START,
        TASK_ID,
        TYPE
    FROM transform_data 
)
select * from type_data