{{ config(
        alias = 'CUSTOMER_SITE_SERVICE_MANAGER_MAPPING',
        materialized='incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        jsonfield:fields.Title::String as CUSTOMER_CODE,
        jsonfield:fields.field_1::String as BU,
        jsonfield:fields.field_2::String as CC_BU_KEY,
        jsonfield:fields.field_3::String as PRIMARY_CONTACT,
        jsonfield:fields.field_4::String as PRIMARY_CONTACTID,
        jsonfield:fields.field_5::String as SECONDARY_CONTACT,
        jsonfield:fields.field_6::String as SECONDARY_CONTACTID
    from {{ source('SHAREPOINT', 'CUSTOMER_SITE_SERVICE_MANAGER_MAPPING') }} 
    where _FILEDATE = (select max(_FILEDATE) from {{ source('SHAREPOINT', 'CUSTOMER_SITE_SERVICE_MANAGER_MAPPING') }})
),

transform_data as (
    select 
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        CUSTOMER_CODE,
        BU,
        CC_BU_KEY,
        PRIMARY_CONTACT,
        PRIMARY_CONTACTID,
        SECONDARY_CONTACT,
        SECONDARY_CONTACTID
    from source_data
),

type_data as (
    select 
        _FILENAME,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(_UPLOADDATE as TIMESTAMP_NTZ(9)) as _UPLOADDATE,
        _AUDIT_LOG_ID,
        _ROW_HASH,
        CUSTOMER_CODE,
        BU,
        CC_BU_KEY,
        PRIMARY_CONTACT,
        PRIMARY_CONTACTID,
        SECONDARY_CONTACT,
        SECONDARY_CONTACTID
    from transform_data
)

select * from type_data