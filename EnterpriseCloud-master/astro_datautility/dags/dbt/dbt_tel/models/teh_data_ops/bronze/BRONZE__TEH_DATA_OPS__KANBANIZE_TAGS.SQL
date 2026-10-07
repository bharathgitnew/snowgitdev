
{{ config(
    alias = 'KANBANIZE_TAGS',
    materialized = 'tel_incremental',
    incremental_strategy = 'merge',
    unique_key = ['TAG_ID'],
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        JSONFIELD:tag_id::STRING as TAG_ID,
        JSONFIELD:label::STRING as LABEL,
        JSONFIELD:color::STRING as COLOR,
        JSONFIELD:availability::STRING as AVAILABILITY,
        JSONFIELD:is_enabled::STRING as IS_ENABLED,
    from {{ source('KANBANIZE', 'TAGS') }} 
    {% if is_tel_incremental() %}where _FILEDATE > ifnull((select max(_FILEDATE) from {{this}}), '1970-01-01'){% endif %}
    qualify row_number() over (partition by TAG_ID order by _FILEDATE desc) = 1
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        TAG_ID,
        LABEL,
        COLOR,
        AVAILABILITY,
        IS_ENABLED,
    from source_data
),

type_data as (
    select 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        TAG_ID,
        LABEL,
        COLOR,
        AVAILABILITY,
        IS_ENABLED,
    from transform_data
)

select * from type_data
