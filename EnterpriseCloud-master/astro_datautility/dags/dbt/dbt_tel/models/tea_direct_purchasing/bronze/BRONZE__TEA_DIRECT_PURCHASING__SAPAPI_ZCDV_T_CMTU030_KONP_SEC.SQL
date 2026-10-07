{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias='SAPAPI_ZCDV_T_CMTU030_KONP_SEC',
        transient=false
) }}

with source_data as (
    select
        _FILEDATE,
        _FILENAME,
        JSONFIELD:Knumh::STRING AS KNUMH,
        JSONFIELD:Kopos::STRING AS KOPOS,
        JSONFIELD:Kbetr::STRING AS KBETR
    from {{ source('SAPAPI','ZCDV_T_CMTU030_KONP_SEC') }}
    {% if is_tel_incremental() %}WHERE  _FILEDATE > IFNULL((SELECT MAX(_FILEDATE) FROM {{ this }}),'1970-01-01'){% endif %}
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY KNUMH,KOPOS ORDER BY _FILENAME DESC, _FILEDATE DESC )) = 1
),

transform_data as (
    select
        _FILEDATE,
        _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.
        KNUMH,
        KOPOS,
        KBETR
    from source_data
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        _AUDIT_LOG_ID,
        _ROW_HASH,
        KNUMH,
        KOPOS,
        KBETR
    from transform_data
)

select * from type_data