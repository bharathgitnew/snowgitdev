{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='WISDOM_SURB_DELAY'
) }}

with source_data as 
(
    SELECT
    _FILEDATE,
    MAC_ID,
    ITEM_NO,
    LANG_TYPE,
    DELAY_CD,
    NOTE,
    MOD_DATE,
    MOD_EMP_NO
    FROM {{ ref('ODS__WISDOM__WISDOM_SURB_DELAY') }}
)

,transform_data as 
(
    SELECT
        _FILEDATE as _FILEDATE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        MAC_ID::NUMBER as MAC_ID,
        ITEM_NO::NUMBER as ITEM_NO,
        LANG_TYPE::NUMBER as LANG_TYPE,
        DELAY_CD::NUMBER as DELAY_CD,
        NOTE as NOTE,
        MOD_DATE::DATE as MOD_DATE,
        MOD_EMP_NO as MOD_EMP_NO
    FROM source_data 
)

,type_data as 
(
    SELECT
        _FILEDATE,
        AUDIT_LOG_ID,
        _ROW_HASH,
        MAC_ID,
        ITEM_NO,
        LANG_TYPE,
        DELAY_CD,
        NOTE,
        MOD_DATE,
        MOD_EMP_NO
    FROM transform_data 
)
select * from type_data