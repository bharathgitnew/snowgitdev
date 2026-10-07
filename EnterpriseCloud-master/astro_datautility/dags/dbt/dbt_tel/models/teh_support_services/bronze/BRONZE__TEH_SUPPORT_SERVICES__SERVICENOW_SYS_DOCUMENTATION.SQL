{{ config(
    alias = 'SERVICENOW_SYS_DOCUMENTATION',
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
        JSONFIELD:"plural"::string as PLURAL,
        JSONFIELD:"language"::string as LANGUAGE,
        JSONFIELD:"label"::string as LABEL,
        JSONFIELD:"sys_class_name"::string as SYS_CLASS_NAME,
        JSONFIELD:"url"::string as URL,
        JSONFIELD:"help"::string as HELP,
        JSONFIELD:"sys_package"::string as SYS_PACKAGE,
        JSONFIELD:"sys_update_name"::string as SYS_UPDATE_NAME,
        JSONFIELD:"url_target"::string as URL_TARGET,
        JSONFIELD:"hint"::string as HINT,
        JSONFIELD:"name"::string as NAME,
        JSONFIELD:"sys_name"::string as SYS_NAME,
        JSONFIELD:"sys_scope"::string as SYS_SCOPE,
        JSONFIELD:"element"::string as ELEMENT,
        JSONFIELD:"sys_policy"::string as SYS_POLICY,
    from {{ source('SERVICENOW', 'SYS_DOCUMENTATION') }} 
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
        PLURAL::VARCHAR(16777216) as PLURAL,
        LANGUAGE::VARCHAR(16777216) as LANGUAGE,
        LABEL::VARCHAR(16777216) as LABEL,
        SYS_CLASS_NAME::VARCHAR(16777216) as SYS_CLASS_NAME,
        URL::VARCHAR(16777216) as URL,
        HELP::VARCHAR(16777216) as HELP,
        SYS_PACKAGE::VARCHAR(16777216) as SYS_PACKAGE,
        SYS_UPDATE_NAME::VARCHAR(16777216) as SYS_UPDATE_NAME,
        URL_TARGET::VARCHAR(16777216) as URL_TARGET,
        HINT::VARCHAR(16777216) as HINT,
        NAME::VARCHAR(16777216) as NAME,
        SYS_NAME::VARCHAR(16777216) as SYS_NAME,
        SYS_SCOPE::VARCHAR(16777216) as SYS_SCOPE,
        ELEMENT::VARCHAR(16777216) as ELEMENT,
        SYS_POLICY::VARCHAR(16777216) as SYS_POLICY,
    from transform_data
)

select * from type_data
