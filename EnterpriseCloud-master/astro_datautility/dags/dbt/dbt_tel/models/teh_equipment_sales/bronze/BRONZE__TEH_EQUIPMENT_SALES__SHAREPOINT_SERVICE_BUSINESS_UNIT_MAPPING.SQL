{{ config(
        alias='SHAREPOINT_SERVICE_BUSINESS_UNIT_MAPPING',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        jsonfield:fields.Title::STRING AS BU_SOURCE_KEY,
        jsonfield:fields.field_1::STRING as LEGACY_BU,
        jsonfield:fields.field_2::STRING as BU_GROUP,
        jsonfield:fields.field_3::STRING as BU_GROUP_LEADER,
        jsonfield:fields.field_4::STRING as BU_GROUP_LEADER_ID,
        jsonfield:fields.field_5::STRING as SERVICE_SEGMENT_CODE_ORACLE,
        jsonfield:fields.field_6::STRING as SERVICE_COST_CENTER,
        jsonfield:fields.field_7::STRING as BU_GROUP2
    from {{ source('SHAREPOINT', 'SERVICE_BUSINESS_UNIT_MAPPING') }}
    where _FILEDATE = (select max(_FILEDATE) from {{ source('SHAREPOINT', 'SERVICE_BUSINESS_UNIT_MAPPING') }})
),

transform_data as (
    select
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _UPLOADDATE,
        BU_SOURCE_KEY,
        LEGACY_BU,
        BU_GROUP,
        BU_GROUP_LEADER,
        BU_GROUP_LEADER_ID,
        SERVICE_SEGMENT_CODE_ORACLE,
        SERVICE_COST_CENTER,
        BU_GROUP2
from source_data
),

type_data as (
    select
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        _UPLOADDATE,
        BU_SOURCE_KEY,
        LEGACY_BU,
        BU_GROUP,
        BU_GROUP_LEADER,
        BU_GROUP_LEADER_ID,
        SERVICE_SEGMENT_CODE_ORACLE,
        SERVICE_COST_CENTER,
        BU_GROUP2
from transform_data
)

select * from type_data