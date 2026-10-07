{{ config(
    alias = 'SERVICENOW_TASK_SLA',
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
        JSONFIELD:"pause_duration"::string as PAUSE_DURATION,
        JSONFIELD:"pause_time"::string as PAUSE_TIME,
        JSONFIELD:"timezone"::string as TIMEZONE,
        JSONFIELD:"business_time_left"::string as BUSINESS_TIME_LEFT,
        JSONFIELD:"duration"::string as DURATION,
        JSONFIELD:"time_left"::string as TIME_LEFT,
        JSONFIELD:"percentage"::string as PERCENTAGE,
        JSONFIELD:"original_breach_time"::string as ORIGINAL_BREACH_TIME,
        JSONFIELD:"business_percentage"::string as BUSINESS_PERCENTAGE,
        JSONFIELD:"u_assigned_to"::string as U_ASSIGNED_TO,
        JSONFIELD:"end_time"::string as END_TIME,
        JSONFIELD:"u_assignment_group"::string as U_ASSIGNMENT_GROUP,
        JSONFIELD:"active"::string as ACTIVE,
        JSONFIELD:"business_pause_duration"::string as BUSINESS_PAUSE_DURATION,
        JSONFIELD:"sla"::string as SLA,
        JSONFIELD:"sys_tags"::string as SYS_TAGS,
        JSONFIELD:"schedule"::string as SCHEDULE,
        JSONFIELD:"start_time"::string as START_TIME,
        JSONFIELD:"business_duration"::string as BUSINESS_DURATION,
        JSONFIELD:"task"::string as TASK,
        JSONFIELD:"stage"::string as STAGE,
        JSONFIELD:"planned_end_time"::string as PLANNED_END_TIME,
        JSONFIELD:"has_breached"::string as HAS_BREACHED,
    from {{ source('SERVICENOW', 'TASK_SLA') }} 
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
        PAUSE_DURATION::VARCHAR(16777216) as PAUSE_DURATION,
        convert_timezone('UTC', 'America/Chicago', PAUSE_TIME) as PAUSE_TIME,
        TIMEZONE::VARCHAR(16777216) as TIMEZONE,
        BUSINESS_TIME_LEFT::VARCHAR(16777216) as BUSINESS_TIME_LEFT,
        DURATION::VARCHAR(16777216) as DURATION,
        TIME_LEFT::VARCHAR(16777216) as TIME_LEFT,
        PERCENTAGE::VARCHAR(16777216) as PERCENTAGE,
        convert_timezone('UTC', 'America/Chicago', ORIGINAL_BREACH_TIME) as ORIGINAL_BREACH_TIME,
        BUSINESS_PERCENTAGE::VARCHAR(16777216) as BUSINESS_PERCENTAGE,
        U_ASSIGNED_TO::VARCHAR(16777216) as U_ASSIGNED_TO,
        convert_timezone('UTC', 'America/Chicago', END_TIME) as END_TIME,
        U_ASSIGNMENT_GROUP::VARCHAR(16777216) as U_ASSIGNMENT_GROUP,
        ACTIVE::BOOLEAN as ACTIVE,
        BUSINESS_PAUSE_DURATION::VARCHAR(16777216) as BUSINESS_PAUSE_DURATION,
        SLA::VARCHAR(16777216) as SLA,
        SYS_TAGS::VARCHAR(16777216) as SYS_TAGS,
        SCHEDULE::VARCHAR(16777216) as SCHEDULE,
        convert_timezone('UTC', 'America/Chicago', START_TIME) as START_TIME,
        BUSINESS_DURATION::VARCHAR(16777216) as BUSINESS_DURATION,
        TASK::VARCHAR(16777216) as TASK,
        STAGE::VARCHAR(16777216) as STAGE,
        convert_timezone('UTC', 'America/Chicago', PLANNED_END_TIME) as PLANNED_END_TIME,
        HAS_BREACHED::BOOLEAN as HAS_BREACHED,
    from transform_data
)

select * from type_data
