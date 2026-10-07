{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='SAPO_MATERIAL_GROUP_DESCRIPTIONS',
    unique_key = ['MANDT',
    'SPRAS',
    'MATKL']
) }}

with source_data as
(
    SELECT
        _CAPTUREDATETIME,
        MANDT,
        SPRAS,
        MATKL,
        WGBEZ,
        WGBEZ60
        FROM {{ source("SAP_ORACLE_LIVE", "T023T") }}
)
,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        _CAPTUREDATETIME,
        MANDT,
        SPRAS,
        MATKL,
        WGBEZ,
        WGBEZ60
        FROM source_data
)
,type_data as
(
    select
        CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
        CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
        CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
        MANDT,
        SPRAS,
        MATKL,
        WGBEZ,
        WGBEZ60
    from transform_data
)
select * from type_data