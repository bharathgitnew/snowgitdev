{{ config(
    alias = 'SHAREPOINT_TMEA_MACHINE_EXPORT_PRICING',
    materialized = 'tel_incremental',
    incremental_strategy = 'merge',
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        JSONFIELD:"DELIVERY_NUMBER"::string as DELIVERY_NUMBER,
        JSONFIELD:"DELIVERY_ITEM"::string as DELIVERY_ITEM,
        JSONFIELD:"PRICE_EACH"::string as PRICE_EACH,
    from {{ source('SHAREPOINT', 'TMEA_MACHINE_EXPORT_PRICING') }} 
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        *
    from source_data
),

type_data as (
    select 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        DELIVERY_NUMBER,
        DELIVERY_ITEM,
        PRICE_EACH,
    from transform_data
)

select * from type_data
