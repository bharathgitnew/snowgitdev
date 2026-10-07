{{ config(
        alias='SHAREPOINT_PRICING_ADJUSTMENT_EXCHANGE_RATES',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        jsonfield:fields.EXCHANGE_RATE_TYPE::String as EXCHANGE_RATE_TYPE,
        jsonfield:fields.FROM_CURRENCY::String as FROM_CURRENCY,
        jsonfield:fields.TO_CURRENCY::String as TO_CURRENCY,
        jsonfield:fields.VALID_FROM::String as VALID_FROM,
        jsonfield:fields.EXCHANGE_RATE::NUMBER(38,2) as EXCHANGE_RATE
    from {{ source('SHAREPOINT', 'PRICING_ADJUSTMENT_EXCHANGE_RATES') }} 
    where _FILEDATE = (select max(_FILEDATE) from {{ source('SHAREPOINT', 'PRICING_ADJUSTMENT_EXCHANGE_RATES') }})
),transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        EXCHANGE_RATE_TYPE,
        FROM_CURRENCY,
        TO_CURRENCY,
        VALID_FROM,
        EXCHANGE_RATE
    from source_data
),

type_data as (
    select 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _FILENAME,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(_UPLOADDATE as TIMESTAMP_NTZ(9)) as _UPLOADDATE,
        EXCHANGE_RATE_TYPE,
        FROM_CURRENCY,
        TO_CURRENCY,
        TRY_TO_TIMESTAMP_NTZ(VALID_FROM) as VALID_FROM,
        EXCHANGE_RATE
    from transform_data
)

select * from type_data