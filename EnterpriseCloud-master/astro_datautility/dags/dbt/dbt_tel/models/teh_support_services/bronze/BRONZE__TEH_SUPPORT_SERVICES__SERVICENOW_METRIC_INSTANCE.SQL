{{ config(
    alias = 'SERVICENOW_METRIC_INSTANCE',
    materialized = 'tel_incremental',
    incremental_strategy = 'merge',
    unique_key = ['SYS_ID'],
) }}

with source_data as (
    select
        _FILEDATE,
        JSONFIELD:"sys_id"::VARCHAR(16777216) as SYS_ID,
        JSONFIELD:"sys_created_on"::string as SYS_CREATED_ON,
        JSONFIELD:"sys_created_by"::string as SYS_CREATED_BY,
        JSONFIELD:"sys_updated_on"::string as SYS_UPDATED_ON,
        JSONFIELD:"sys_updated_by"::string as SYS_UPDATED_BY,
        JSONFIELD:"sys_mod_count"::string as SYS_MOD_COUNT,        
        JSONFIELD:"start"::string as START_DATETIME,
        JSONFIELD:"calculation_complete"::string as CALCULATION_COMPLETE,
        JSONFIELD:"duration"::string as DURATION,
        JSONFIELD:"business_duration"::string as BUSINESS_DURATION,
        JSONFIELD:"field"::string as FIELD,
        JSONFIELD:"u_task"::string as U_TASK,
        JSONFIELD:"field_value"::string as FIELD_VALUE,
        JSONFIELD:"definition"::string as DEFINITION,
        JSONFIELD:"end"::string as END_DATETIME,
        JSONFIELD:"id"::string as ID,
        JSONFIELD:"value"::string as VALUE,
        JSONFIELD:"table"::string as TABLE_NAME,
    from {{ source('SERVICENOW', 'METRIC_INSTANCE') }} 
    where _FILEDATE > ifnull((select max(_FILEDATE) from {{ this }}), '1970-01-01')
    qualify row_number() over (partition by SYS_ID order by _FILEDATE desc, _UPLOADDATE desc) = 1
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        current_timestamp()::timestamp_ntz as _REFRESHDATE,
        *,
    from source_data
),

type_data as (
    select 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _FILEDATE,
        _REFRESHDATE,
        SYS_ID::VARCHAR(16777216) as SYS_ID,
        convert_timezone('UTC', 'America/Chicago', SYS_CREATED_ON) as SYS_CREATED_ON,
        SYS_CREATED_BY::VARCHAR(16777216) as SYS_CREATED_BY,
        convert_timezone('UTC', 'America/Chicago', SYS_UPDATED_ON) as SYS_UPDATED_ON,
        SYS_UPDATED_BY::VARCHAR(16777216) as SYS_UPDATED_BY,
        SYS_MOD_COUNT::NUMBER(38,0) as SYS_MOD_COUNT,
        convert_timezone('UTC', 'America/Chicago', START_DATETIME) as START_DATETIME,
        CALCULATION_COMPLETE::BOOLEAN as CALCULATION_COMPLETE,
        DURATION::VARCHAR(16777216) as DURATION,
        BUSINESS_DURATION::VARCHAR(16777216) as BUSINESS_DURATION,
        FIELD::VARCHAR(16777216) as FIELD,
        U_TASK::VARCHAR(16777216) as U_TASK,
        FIELD_VALUE::VARCHAR(16777216) as FIELD_VALUE,
        DEFINITION::VARCHAR(16777216) as DEFINITION,
        convert_timezone('UTC', 'America/Chicago', END_DATETIME) as END_DATETIME,
        ID::VARCHAR(16777216) as ID,
        VALUE::VARCHAR(16777216) as VALUE,
        TABLE_NAME::VARCHAR(16777216) as TABLE_NAME,
    from transform_data
)

select * from type_data
