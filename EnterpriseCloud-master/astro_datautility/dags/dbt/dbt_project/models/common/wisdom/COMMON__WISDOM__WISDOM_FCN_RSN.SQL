{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='WISDOM_FCN_RSN'
) }}

with source_data as 
(
    SELECT
    _FILEDATE,
    MAC_SN, 
    NCR_NO, 
    DELAY_RSN_CAT_ID,
    DELAY_RSN_CAT_NAME AS "DELAY_RSN_CAT",
    UNNEC_RSN_CAT_ID, 
    UNNEC_RSN_CAT_NAME AS "UNNEC_RSN_CAT", 
    UPGRADE_NO
    FROM {{ ref('ODS__WISDOM__UPGRADE_LIST_FCN_RSN') }}
    where NCR_NO is not null
        and (DELAY_RSN_CAT_NAME is not null OR UNNEC_RSN_CAT_NAME is not null) 
)

,transform_data as 
(
    SELECT
        _FILEDATE as _FILEDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        MAC_SN, 
        NCR_NO, 
        DELAY_RSN_CAT_ID,
        DELAY_RSN_CAT,
        UNNEC_RSN_CAT_ID, 
        UNNEC_RSN_CAT, 
        UPGRADE_NO
    FROM source_data 
)

,type_data as 
(
    SELECT
        _FILEDATE,
        _AUDIT_LOG_ID,
        _ROW_HASH,
        MAC_SN, 
        NCR_NO, 
        DELAY_RSN_CAT_ID,
        DELAY_RSN_CAT,
        UNNEC_RSN_CAT_ID, 
        UNNEC_RSN_CAT, 
        UPGRADE_NO
    FROM transform_data 
)
select * from type_data