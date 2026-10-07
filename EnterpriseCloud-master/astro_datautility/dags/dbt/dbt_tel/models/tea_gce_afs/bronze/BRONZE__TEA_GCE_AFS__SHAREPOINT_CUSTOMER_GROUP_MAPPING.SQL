{{ config(
        alias='SHAREPOINT_CUSTOMER_GROUP_MAPPING',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        jsonfield:fields.Title::String as ACCOUNT_NUMBER,
        jsonfield:fields.field_1::String as CUSTOMER_GROUP,
        jsonfield:fields.field_2::String as CUSTOMER_GROUP2
    from {{ source('SHAREPOINT', 'CUSTOMER_GROUP_MAPPING') }}
    where _FILEDATE = (select max(_FILEDATE) from {{ source('SHAREPOINT', 'CUSTOMER_GROUP_MAPPING') }})
),

transform_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
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
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        ACCOUNT_NUMBER,
        CUSTOMER_GROUP,
        CUSTOMER_GROUP2
    from transform_data
)

select * from type_data