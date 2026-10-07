{{ config(
    alias = 'SERVICENOW_LABEL',
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
        JSONFIELD:"short_description"::string as SHORT_DESCRIPTION,
        JSONFIELD:"color"::string as COLOR,
        JSONFIELD:"roles"::string as ROLES,
        JSONFIELD:"icon"::string as ICON,
        JSONFIELD:"global"::string as GLOBAL,
        JSONFIELD:"type"::string as TYPE,
        JSONFIELD:"sys_class_name"::string as SYS_CLASS_NAME,
        JSONFIELD:"max_entries"::string as MAX_ENTRIES,
        JSONFIELD:"home_page"::string as HOME_PAGE,
        JSONFIELD:"navigation"::string as NAVIGATION,
        JSONFIELD:"viewable_by"::string as VIEWABLE_BY,
        JSONFIELD:"sys_default"::string as SYS_DEFAULT,
        JSONFIELD:"order"::string as ORDER_NUMBER,
        JSONFIELD:"owner"::string as OWNER,
        JSONFIELD:"active"::string as ACTIVE,
        JSONFIELD:"user_list"::string as USER_LIST,
        JSONFIELD:"sys_tags"::string as SYS_TAGS,
        JSONFIELD:"group_list"::string as GROUP_LIST,
        JSONFIELD:"background_color"::string as BACKGROUND_COLOR,
        JSONFIELD:"name"::string as NAME,
    from {{ source('SERVICENOW', 'LABEL') }} 
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
        SHORT_DESCRIPTION::VARCHAR(16777216) as SHORT_DESCRIPTION,
        COLOR::VARCHAR(16777216) as COLOR,
        ROLES::VARCHAR(16777216) as ROLES,
        ICON::VARCHAR(16777216) as ICON,
        GLOBAL::BOOLEAN as GLOBAL,
        TYPE::VARCHAR(16777216) as TYPE,
        SYS_CLASS_NAME::VARCHAR(16777216) as SYS_CLASS_NAME,
        MAX_ENTRIES::NUMBER(38,0) as MAX_ENTRIES,
        HOME_PAGE::BOOLEAN as HOME_PAGE,
        NAVIGATION::BOOLEAN as NAVIGATION,
        VIEWABLE_BY::VARCHAR(16777216) as VIEWABLE_BY,
        SYS_DEFAULT::BOOLEAN as SYS_DEFAULT,
        ORDER_NUMBER::NUMBER(38,10) as ORDER_NUMBER,
        OWNER::VARCHAR(16777216) as OWNER,
        ACTIVE::BOOLEAN as ACTIVE,
        USER_LIST::VARCHAR(16777216) as USER_LIST,
        SYS_TAGS::VARCHAR(16777216) as SYS_TAGS,
        GROUP_LIST::VARCHAR(16777216) as GROUP_LIST,
        BACKGROUND_COLOR::VARCHAR(16777216) as BACKGROUND_COLOR,
        NAME::VARCHAR(16777216) as NAME,
    from transform_data
)

select * from type_data
