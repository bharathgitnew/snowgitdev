
{{ config(
    alias = 'KANBANIZE_USERS',
    materialized = 'tel_incremental',
    incremental_strategy = 'merge',
    unique_key = ['USER_ID'],
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        JSONFIELD:user_id::STRING as USER_ID,
        JSONFIELD:username::STRING as USERNAME,
        JSONFIELD:realname::STRING as REALNAME,
        JSONFIELD:avatar::STRING as AVATAR,
        JSONFIELD:attributes::STRING as ATTRIBUTES,
    from {{ source('KANBANIZE', 'USERS') }} 
    {% if is_tel_incremental() %}where _FILEDATE > ifnull((select max(_FILEDATE) from {{this}}), '1970-01-01'){% endif %}
    qualify row_number() over (partition by USER_ID order by _FILEDATE desc) = 1
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        USER_ID,
        USERNAME,
        REALNAME,
        AVATAR,
        ATTRIBUTES,
    from source_data
),

type_data as (
    select 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        USER_ID,
        USERNAME,
        REALNAME,
        AVATAR,
        ATTRIBUTES,
    from transform_data
)

select * from type_data
