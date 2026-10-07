{{ config(
        alias='FILE_CUSTOMER_SITE_SERVICE_MANAGER_MAPPING',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        CUSTOMER_CODE,
        BU,
        CC_BU_KEY,
        PRIMARY_CONTACT,
        PRIMARY_CONTACTID,
        SECONDARY_CONTACT,
        SECONDARY_CONTACTID
    from {{ source('FILE', 'CUSTOMER_SITE_SERVICE_MANAGER_MAPPING') }} 
    where _FILEDATE = (select max(_FILEDATE) from {{ source('FILE', 'CUSTOMER_SITE_SERVICE_MANAGER_MAPPING') }})
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
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
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _FILENAME,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(_UPLOADDATE as TIMESTAMP_NTZ(9)) as _UPLOADDATE,
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