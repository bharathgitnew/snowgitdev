{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SHAREPOINT_SIRFIS_PRICE_ESTIMATE_INLINE'
) }}

with source_data as
(
    select 
    _FILENAME,
    _FILEDATE,
    _UPLOADDATE,
    jsonfield:fields.Title::varchar as PRICE_KEY,
    jsonfield:fields.field_1::varchar as PRICE_ESTIMATE
    FROM {{ source("SHAREPOINT", "SIRFIS_PRICE_ESTIMATE_INLINE") }}
    {% if is_tel_incremental() %}
    where _UPLOADDATE = (select max(_UPLOADDATE) from {{ source("SHAREPOINT", "SIRFIS_PRICE_ESTIMATE_INLINE") }})
    {% endif %}
)
,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        PRICE_KEY,
        PRICE_ESTIMATE
        FROM source_data
)

,type_data as
(
    select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        PRICE_KEY,
        CAST(PRICE_ESTIMATE AS NUMBER(38,0)) AS PRICE_ESTIMATE
    from transform_data
    )
select * from type_data