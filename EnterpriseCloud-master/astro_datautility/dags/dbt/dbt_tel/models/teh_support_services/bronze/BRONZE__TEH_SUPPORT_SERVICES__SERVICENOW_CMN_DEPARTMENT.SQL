{{ config(
    alias = 'SERVICENOW_CMN_DEPARTMENT',
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
        JSONFIELD:"description"::string as DESCRIPTION,
        JSONFIELD:"head_count"::string as HEAD_COUNT,
        JSONFIELD:"sys_tags"::string as SYS_TAGS,
        JSONFIELD:"business_unit"::string as BUSINESS_UNIT,
        JSONFIELD:"dept_head"::string as DEPT_HEAD,
        JSONFIELD:"cost_center"::string as COST_CENTER,
        JSONFIELD:"name"::string as NAME,
        JSONFIELD:"company"::string as COMPANY,
        JSONFIELD:"id"::string as ID,
        JSONFIELD:"parent_hp1"::string as PARENT_HP1,
        JSONFIELD:"primary_contact"::string as PRIMARY_CONTACT,
    from {{ source('SERVICENOW', 'CMN_DEPARTMENT') }} 
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
        DESCRIPTION::VARCHAR(16777216) as DESCRIPTION,
        HEAD_COUNT::NUMBER(38,0) as HEAD_COUNT,
        SYS_TAGS::VARCHAR(16777216) as SYS_TAGS,
        BUSINESS_UNIT::VARCHAR(16777216) as BUSINESS_UNIT,
        DEPT_HEAD::VARCHAR(16777216) as DEPT_HEAD,
        COST_CENTER::VARCHAR(16777216) as COST_CENTER,
        NAME::VARCHAR(16777216) as NAME,
        COMPANY::VARCHAR(16777216) as COMPANY,
        ID::VARCHAR(16777216) as ID,
        PARENT_HP1::VARCHAR(16777216) as PARENT_HP1,
        PRIMARY_CONTACT::VARCHAR(16777216) as PRIMARY_CONTACT,
    from transform_data
)

select * from type_data
