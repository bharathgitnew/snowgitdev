{{ config(
    alias = 'SERVICENOW_LABEL_ENTRY',
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
        JSONFIELD:"auto"::string as AUTO,
        JSONFIELD:"comments"::string as COMMENTS,
        JSONFIELD:"read"::string as READ,
        JSONFIELD:"notify_onchange"::string as NOTIFY_ONCHANGE,
        JSONFIELD:"label"::string as LABEL,
        JSONFIELD:"sys_tags"::string as SYS_TAGS,
        JSONFIELD:"title"::string as TITLE,
        JSONFIELD:"url"::string as URL,
        JSONFIELD:"table_key"::string as TABLE_KEY,
        JSONFIELD:"id_display"::string as ID_DISPLAY,
        JSONFIELD:"notify_when"::string as NOTIFY_WHEN,
        JSONFIELD:"id_type"::string as ID_TYPE,
        JSONFIELD:"reference_count"::string as REFERENCE_COUNT,
        JSONFIELD:"notify_script"::string as NOTIFY_SCRIPT,
        JSONFIELD:"table"::string as TABLE_NAME,
        JSONFIELD:"view_name"::string as VIEW_NAME,
    from {{ source('SERVICENOW', 'LABEL_ENTRY') }} 
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
        AUTO::VARCHAR(16777216) as AUTO,
        COMMENTS::VARCHAR(16777216) as COMMENTS,
        READ::VARCHAR(16777216) as READ,
        NOTIFY_ONCHANGE::BOOLEAN as NOTIFY_ONCHANGE,
        LABEL::VARCHAR(16777216) as LABEL,
        SYS_TAGS::VARCHAR(16777216) as SYS_TAGS,
        TITLE::VARCHAR(16777216) as TITLE,
        URL::VARCHAR(16777216) as URL,
        TABLE_KEY::VARCHAR(16777216) as TABLE_KEY,
        ID_DISPLAY::VARCHAR(16777216) as ID_DISPLAY,
        NOTIFY_WHEN::VARCHAR(16777216) as NOTIFY_WHEN,
        ID_TYPE::VARCHAR(16777216) as ID_TYPE,
        REFERENCE_COUNT::NUMBER(38,0) as REFERENCE_COUNT,
        NOTIFY_SCRIPT::VARCHAR(16777216) as NOTIFY_SCRIPT,
        TABLE_NAME::VARCHAR(16777216) as TABLE_NAME,
        VIEW_NAME::VARCHAR(16777216) as VIEW_NAME,
    from transform_data
)

select * from type_data
