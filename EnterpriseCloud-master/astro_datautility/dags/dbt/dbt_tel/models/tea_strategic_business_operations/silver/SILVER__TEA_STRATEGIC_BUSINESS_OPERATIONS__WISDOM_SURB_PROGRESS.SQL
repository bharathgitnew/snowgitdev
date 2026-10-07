{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='WISDOM_SURB_PROGRESS'
) }}

with source_data    as 
        ( 
    SELECT
      _FILEDATE,
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
    FROM  {{ ref('BRONZE__TEA_STRATEGIC_BUSINESS_OPERATIONS__WISDOM_WISDOM_SURB_PROGRESS') }}
)

,transform_data as 
(
    SELECT
        _FILEDATE as _FILEDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
            ACK_DT::DATE as ACK_DT,
        ACK_EMP_NO as ACK_EMP_NO,
        ACTUAL_COMMENT as ACTUAL_COMMENT,
        ACTUAL_END::DATE as ACTUAL_END,
        ACTUAL_START::DATE as ACTUAL_START,
        COMMENT_CTG_ID as COMMENT_CTG_ID,
        DAYS::NUMBER as DAYS,
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
        _AUDIT_LOG_ID,
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