{{ config(
    alias = 'SERVICENOW_SYS_CHOICE',
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
        JSONFIELD:"dependent_value"::string as DEPENDENT_VALUE,
        JSONFIELD:"synonyms"::string as SYNONYMS,
        JSONFIELD:"language"::string as LANGUAGE,
        JSONFIELD:"label"::string as LABEL,
        JSONFIELD:"sys_domain_path"::string as SYS_DOMAIN_PATH,
        JSONFIELD:"sys_tags"::string as SYS_TAGS,
        JSONFIELD:"sequence"::string as SEQUENCE,
        JSONFIELD:"inactive"::string as INACTIVE,
        JSONFIELD:"hint"::string as HINT,
        JSONFIELD:"sys_domain"::string as SYS_DOMAIN,
        JSONFIELD:"name"::string as NAME,
        JSONFIELD:"value"::string as VALUE,
        JSONFIELD:"element"::string as ELEMENT,
    from {{ source('SERVICENOW', 'SYS_CHOICE') }} 
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
        DEPENDENT_VALUE::VARCHAR(16777216) as DEPENDENT_VALUE,
        SYNONYMS::VARCHAR(16777216) as SYNONYMS,
        LANGUAGE::VARCHAR(16777216) as LANGUAGE,
        LABEL::VARCHAR(16777216) as LABEL,
        SYS_DOMAIN_PATH::VARCHAR(16777216) as SYS_DOMAIN_PATH,
        SYS_TAGS::VARCHAR(16777216) as SYS_TAGS,
        SEQUENCE::NUMBER(38,0) as SEQUENCE,
        INACTIVE::BOOLEAN as INACTIVE,
        HINT::VARCHAR(16777216) as HINT,
        SYS_DOMAIN::VARCHAR(16777216) as SYS_DOMAIN,
        NAME::VARCHAR(16777216) as NAME,
        VALUE::VARCHAR(16777216) as VALUE,
        ELEMENT::VARCHAR(16777216) as ELEMENT,
    from transform_data
)

select * from type_data
