{{ config(
        alias = 'SHAREPOINT_CUSTOMER_MAPPING_SERVICE',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite'
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        jsonfield:fields.Title::STRING as CUSTOMER_CODE,
        jsonfield:fields.field_1::STRING as CUSTOMER_NAME_COMMON,
        jsonfield:fields.field_2::STRING as CUSTOMER_NAME_SOURCE,
        jsonfield:fields.field_3::STRING as CUSTOMER_SHORT_NAME,
        jsonfield:fields.field_4::STRING as SAP_CORPORATION_CODE,
        jsonfield:fields.field_5::STRING as CUSTOMER_SOURCE,
        jsonfield:fields.field_6::STRING as CUSTOMER_FLAG,
        jsonfield:fields.field_7::STRING as CUSTOMER_FLAG2
    from {{ source('SHAREPOINT', 'CUSTOMER_MAPPING_SERVICE') }}
    where _FILEDATE = (select max(_FILEDATE) from {{ source('SHAREPOINT', 'CUSTOMER_MAPPING_SERVICE') }})
),

transform_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        CUSTOMER_CODE,
        CUSTOMER_NAME_COMMON,
        CUSTOMER_NAME_SOURCE,
        CUSTOMER_SHORT_NAME,
        SAP_CORPORATION_CODE,
        CUSTOMER_SOURCE,
        CUSTOMER_FLAG,
        CUSTOMER_FLAG2
    from source_data
),

type_data as (
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        CUSTOMER_CODE,
        CUSTOMER_NAME_COMMON,
        CUSTOMER_NAME_SOURCE,
        CUSTOMER_SHORT_NAME,
        SAP_CORPORATION_CODE,
        CUSTOMER_SOURCE,
        CUSTOMER_FLAG,
        CUSTOMER_FLAG2
    from transform_data
)

select * from type_data