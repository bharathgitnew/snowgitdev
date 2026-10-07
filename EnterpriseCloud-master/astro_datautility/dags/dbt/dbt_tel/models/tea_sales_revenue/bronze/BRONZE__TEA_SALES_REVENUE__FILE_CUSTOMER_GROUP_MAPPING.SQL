{{ config(
        alias='FILE_CUSTOMER_GROUP_MAPPING',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        ACCOUNT_NUMBER,
        CUSTOMER_GROUP,
        CUSTOMER_GROUP2
    from {{ source('FILE', 'CUSTOMER_GROUP_MAPPING') }} 
    where _FILEDATE = (select max(_FILEDATE) from {{ source('FILE', 'CUSTOMER_GROUP_MAPPING') }})
),

transform_data as (
    select 
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        ACCOUNT_NUMBER,
        CUSTOMER_GROUP,
        CUSTOMER_GROUP2
    from source_data
),

type_data as (
    select 
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        _AUDIT_LOG_ID,
        _ROW_HASH,
        ACCOUNT_NUMBER,
        CUSTOMER_GROUP,
        CUSTOMER_GROUP2
    from transform_data
)

select * from type_data