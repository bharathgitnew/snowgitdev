{{ config(
    alias = 'SERVICENOW_SYS_USER_GROUP',
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
        JSONFIELD:"parent"::string as PARENT,
        JSONFIELD:"manager"::string as MANAGER,
        JSONFIELD:"roles"::string as ROLES,
        JSONFIELD:"active"::string as ACTIVE,
        JSONFIELD:"description"::string as DESCRIPTION,
        JSONFIELD:"source"::string as SOURCE,
        JSONFIELD:"sys_tags"::string as SYS_TAGS,
        JSONFIELD:"type"::string as TYPE,
        JSONFIELD:"cost_center"::string as COST_CENTER,
        JSONFIELD:"default_assignee"::string as DEFAULT_ASSIGNEE,
        JSONFIELD:"name"::string as NAME,
        JSONFIELD:"exclude_manager"::string as EXCLUDE_MANAGER,
        JSONFIELD:"email"::string as EMAIL,
        JSONFIELD:"include_members"::string as INCLUDE_MEMBERS,
    from {{ source('SERVICENOW', 'SYS_USER_GROUP') }} 
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
        PARENT::VARCHAR(16777216) as PARENT,
        MANAGER::VARCHAR(16777216) as MANAGER,
        ROLES::VARCHAR(16777216) as ROLES,
        ACTIVE::BOOLEAN as ACTIVE,
        DESCRIPTION::VARCHAR(16777216) as DESCRIPTION,
        SOURCE::VARCHAR(16777216) as SOURCE,
        SYS_TAGS::VARCHAR(16777216) as SYS_TAGS,
        TYPE::VARCHAR(16777216) as TYPE,
        COST_CENTER::VARCHAR(16777216) as COST_CENTER,
        DEFAULT_ASSIGNEE::VARCHAR(16777216) as DEFAULT_ASSIGNEE,
        NAME::VARCHAR(16777216) as NAME,
        EXCLUDE_MANAGER::BOOLEAN as EXCLUDE_MANAGER,
        EMAIL::VARCHAR(16777216) as EMAIL,
        INCLUDE_MEMBERS::BOOLEAN as INCLUDE_MEMBERS,
    from transform_data
)

select * from type_data
