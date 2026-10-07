{{ config(
        alias = 'TASTypeOfWork',
        materialized='incremental',
        incremental_strategy = 'insert_overwrite'
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        jsonfield:fields.Title::STRING as TYPE_OF_WORK,
        jsonfield:fields.field_1::STRING as TAS_TYPE_OF_WORK,
        jsonfield:fields.field_2::STRING as TAS_TYPE_OF_WORK_GROUP,
        jsonfield:fields.field_3::STRING as SOURCE,
        jsonfield:fields.field_4::STRING as SERVICE_UTILIZATION_GROUP,
        jsonfield:fields.field_5::STRING as SO_EXPECTED_IN_CRM,
        jsonfield:fields.field_6::STRING as REVENUE_SOURCE,
        jsonfield:fields.field_7::STRING as EXPECTED_SO_SERIES,
        jsonfield:fields.field_8::STRING as LEGACY_TYPE_OF_WORK,
        jsonfield:fields.field_9::STRING as SERVICE_COSTING_PRODUCT_TYPE_CODE,
        jsonfield:fields.field_10::STRING as BILLABLE_CATEGORY_GROUP
    from {{ source('SHAREPOINT', 'TAS_TYPE_OF_WORK_MAPPING') }}
    where _FILEDATE = (select max(_FILEDATE) from {{ source('SHAREPOINT', 'TAS_TYPE_OF_WORK_MAPPING') }})
),

transform_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        TYPE_OF_WORK,
        TAS_TYPE_OF_WORK,
        TAS_TYPE_OF_WORK_GROUP,
        SOURCE,
        SERVICE_UTILIZATION_GROUP,
        SO_EXPECTED_IN_CRM,
        REVENUE_SOURCE,
        EXPECTED_SO_SERIES,
        LEGACY_TYPE_OF_WORK,
        SERVICE_COSTING_PRODUCT_TYPE_CODE,
        BILLABLE_CATEGORY_GROUP
    from source_data
),

type_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        TYPE_OF_WORK,
        TAS_TYPE_OF_WORK,
        TAS_TYPE_OF_WORK_GROUP,
        SOURCE,
        SERVICE_UTILIZATION_GROUP,
        SO_EXPECTED_IN_CRM,
        REVENUE_SOURCE,
        EXPECTED_SO_SERIES,
        LEGACY_TYPE_OF_WORK,
        SERVICE_COSTING_PRODUCT_TYPE_CODE,
        BILLABLE_CATEGORY_GROUP
    from transform_data
)

select * from type_data