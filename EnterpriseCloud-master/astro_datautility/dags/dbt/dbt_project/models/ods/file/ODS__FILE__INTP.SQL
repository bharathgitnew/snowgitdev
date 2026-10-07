{{ config(
    alias = 'INTP',
    materialized='incremental',
    incremental_strategy = 'insert_overwrite',
    meta = {
        'owners': ['Jonathan Wong'],
        'sunset': '2025-07-31',
    },
    enabled = false,
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        PRICE_BOOK,
        ITEM,
        CURRENCY,
        MINIMUM_QUANTITY,
        QUANTITY_UNITS,
        EFFECTIVE_DATE,
        EXPIRATION_DATE,
        ENTRY_DATE,
        BASE_PRICE,
        PRICE_UNIT
    from {{ source('FILE', 'INTP') }} 
    where _FILEDATE = (select max(_FILEDATE) from {{ source('FILE', 'INTP') }})
),

transform_data as (
    select 
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        PRICE_BOOK,
        ITEM,
        CURRENCY,
        MINIMUM_QUANTITY,
        QUANTITY_UNITS,
        EFFECTIVE_DATE,
        EXPIRATION_DATE,
        ENTRY_DATE,
        BASE_PRICE,
        PRICE_UNIT
    from source_data
),

type_data as (
    select 
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        _AUDIT_LOG_ID,
        _ROW_HASH,
        PRICE_BOOK,
        ITEM,
        CURRENCY,
        MINIMUM_QUANTITY,
        QUANTITY_UNITS,
        EFFECTIVE_DATE,
        EXPIRATION_DATE,
        ENTRY_DATE,
        BASE_PRICE,
        PRICE_UNIT
    from transform_data
)

select * from type_data