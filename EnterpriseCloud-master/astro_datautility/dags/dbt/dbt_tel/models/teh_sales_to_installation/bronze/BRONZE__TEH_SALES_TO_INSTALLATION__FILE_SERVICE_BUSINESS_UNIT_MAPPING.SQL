{{ config(
        alias='FILE_SERVICE_BUSINESS_UNIT_MAPPING',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        BU_SOURCE_KEY,
        LEGACY_BU,
        BU_GROUP,
        BU_GROUP_LEADER,
        BU_GROUP_LEADER_ID,
        SERVICE_SEGMENT_CODE_ORACLE,
        SERVICE_COST_CENTER,
        BU_GROUP2
    from {{ source('FILE', 'SERVICE_BUSINESS_UNIT_MAPPING') }} 
    where _FILEDATE = (select max(_FILEDATE) from {{ source('FILE', 'SERVICE_BUSINESS_UNIT_MAPPING') }})
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE, -- Adds column to table on full refresh.
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
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        _FILENAME,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(_UPLOADDATE as TIMESTAMP_NTZ(9)) as _UPLOADDATE,
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