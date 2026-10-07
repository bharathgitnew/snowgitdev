{{ config(
    alias = 'SERVICENOW_METRIC_DEFINITION',
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
        JSONFIELD:"active"::string as ACTIVE,
        JSONFIELD:"description"::string as DESCRIPTION,
        JSONFIELD:"sys_tags"::string as SYS_TAGS,
        JSONFIELD:"type"::string as TYPE,
        JSONFIELD:"script"::string as SCRIPT,
        JSONFIELD:"sys_class_name"::string as SYS_CLASS_NAME,
        JSONFIELD:"number"::string as NUMBER,
        JSONFIELD:"sys_package"::string as SYS_PACKAGE,
        JSONFIELD:"sys_update_name"::string as SYS_UPDATE_NAME,
        JSONFIELD:"field"::string as FIELD,
        JSONFIELD:"name"::string as NAME,
        JSONFIELD:"sys_name"::string as SYS_NAME,
        JSONFIELD:"timeline"::string as TIMELINE,
        JSONFIELD:"sys_scope"::string as SYS_SCOPE,
        JSONFIELD:"table"::string as TABLE_NAME,
        JSONFIELD:"order"::string as ORDER_NUMBER,
        JSONFIELD:"sys_policy"::string as SYS_POLICY,
    from {{ source('SERVICENOW', 'METRIC_DEFINITION') }} 
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
        ACTIVE::BOOLEAN as ACTIVE,
        DESCRIPTION::VARCHAR(16777216) as DESCRIPTION,
        SYS_TAGS::VARCHAR(16777216) as SYS_TAGS,
        TYPE::VARCHAR(16777216) as TYPE,
        SCRIPT::VARCHAR(16777216) as SCRIPT,
        SYS_CLASS_NAME::VARCHAR(16777216) as SYS_CLASS_NAME,
        NUMBER::VARCHAR(16777216) as NUMBER,
        SYS_PACKAGE::VARCHAR(16777216) as SYS_PACKAGE,
        SYS_UPDATE_NAME::VARCHAR(16777216) as SYS_UPDATE_NAME,
        FIELD::VARCHAR(16777216) as FIELD,
        NAME::VARCHAR(16777216) as NAME,
        SYS_NAME::VARCHAR(16777216) as SYS_NAME,
        TIMELINE::BOOLEAN as TIMELINE,
        SYS_SCOPE::VARCHAR(16777216) as SYS_SCOPE,
        TABLE_NAME::VARCHAR(16777216) as TABLE_NAME,
        ORDER_NUMBER::NUMBER(38,0) as ORDER_NUMBER,
        SYS_POLICY::VARCHAR(16777216) as SYS_POLICY,
    from transform_data
)

select * from type_data
