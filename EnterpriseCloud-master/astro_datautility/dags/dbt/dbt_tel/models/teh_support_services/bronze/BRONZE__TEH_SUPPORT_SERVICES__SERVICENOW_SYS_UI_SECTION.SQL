{{ config(
    alias = 'SERVICENOW_SYS_UI_SECTION',
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
        JSONFIELD:"roles"::string as ROLES,
        JSONFIELD:"caption"::string as CAPTION,
        JSONFIELD:"sys_overrides"::string as SYS_OVERRIDES,
        JSONFIELD:"sys_domain_path"::string as SYS_DOMAIN_PATH,
        JSONFIELD:"sys_tags"::string as SYS_TAGS,
        JSONFIELD:"title"::string as TITLE,
        JSONFIELD:"sys_class_name"::string as SYS_CLASS_NAME,
        JSONFIELD:"sys_package"::string as SYS_PACKAGE,
        JSONFIELD:"view"::string as VIEW,
        JSONFIELD:"sys_update_name"::string as SYS_UPDATE_NAME,
        JSONFIELD:"sys_user"::string as SYS_USER,
        JSONFIELD:"sys_domain"::string as SYS_DOMAIN,
        JSONFIELD:"name"::string as NAME,
        JSONFIELD:"header"::string as HEADER,
        JSONFIELD:"sys_name"::string as SYS_NAME,
        JSONFIELD:"sys_scope"::string as SYS_SCOPE,
        JSONFIELD:"sys_policy"::string as SYS_POLICY,
        JSONFIELD:"view_name"::string as VIEW_NAME,
    from {{ source('SERVICENOW', 'SYS_UI_SECTION') }} 
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
        ROLES::VARCHAR(16777216) as ROLES,
        CAPTION::VARCHAR(16777216) as CAPTION,
        SYS_OVERRIDES::VARCHAR(16777216) as SYS_OVERRIDES,
        SYS_DOMAIN_PATH::VARCHAR(16777216) as SYS_DOMAIN_PATH,
        SYS_TAGS::VARCHAR(16777216) as SYS_TAGS,
        TITLE::BOOLEAN as TITLE,
        SYS_CLASS_NAME::VARCHAR(16777216) as SYS_CLASS_NAME,
        SYS_PACKAGE::VARCHAR(16777216) as SYS_PACKAGE,
        VIEW::VARCHAR(16777216) as VIEW,
        SYS_UPDATE_NAME::VARCHAR(16777216) as SYS_UPDATE_NAME,
        SYS_USER::VARCHAR(16777216) as SYS_USER,
        SYS_DOMAIN::VARCHAR(16777216) as SYS_DOMAIN,
        NAME::VARCHAR(16777216) as NAME,
        HEADER::BOOLEAN as HEADER,
        SYS_NAME::VARCHAR(16777216) as SYS_NAME,
        SYS_SCOPE::VARCHAR(16777216) as SYS_SCOPE,
        SYS_POLICY::VARCHAR(16777216) as SYS_POLICY,
        VIEW_NAME::VARCHAR(16777216) as VIEW_NAME,
    from transform_data
)

select * from type_data
