{{ config(
        materialized='incremental'    ,
    incremental_strategy='insert_overwrite'    ,
    alias='WISDOM_SURB_DELAY'    
) }}

with source_data as
(
    SELECT
    JSONFIELD:MAC_ID::NUMBER as MAC_ID,
    JSONFIELD:ITEM_NO::NUMBER as ITEM_NO,
    JSONFIELD:LANG_TYPE::NUMBER as LANG_TYPE,
    JSONFIELD:DELAY_CD::NUMBER as DELAY_CD,
    JSONFIELD:NOTE::STRING as NOTE,
    JSONFIELD:MOD_DATE::STRING as MOD_DATE,
    JSONFIELD:MOD_EMP_NO::STRING as MOD_EMP_NO,
    _filedate as _FILEDATE
    FROM {{ source('WISDOM','WISDOM_SURB_DELAY') }}
),

transform_data as 
(
    SELECT
        _FILEDATE as _FILEDATE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
            MAC_ID as MAC_ID,
        ITEM_NO as ITEM_NO,
        LANG_TYPE as LANG_TYPE,
        DELAY_CD as DELAY_CD,
        NOTE as NOTE,
        MOD_DATE::DATE as MOD_DATE,
        MOD_EMP_NO as MOD_EMP_NO
    FROM source_data 
),
type_data as 
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