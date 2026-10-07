
{{ config(
    alias = 'KANBANIZE_CUSTOMFIELDS_VALUES',
    materialized = 'tel_incremental',
    incremental_strategy = 'merge',
    unique_key = ['FIELD_ID', 'VALUE_ID'],
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        JSONFIELD:field_id::STRING as FIELD_ID,
        JSONFIELD:value_id::STRING as VALUE_ID,
        JSONFIELD:position::STRING as POSITION,
        JSONFIELD:is_enabled::STRING as IS_ENABLED,
        JSONFIELD:is_default::STRING as IS_DEFAULT,
        JSONFIELD:value::STRING as VALUE,
    from {{ source('KANBANIZE', 'CUSTOMFIELDS_VALUES') }} 
    {% if is_tel_incremental() %}where _FILEDATE > ifnull((select max(_FILEDATE) from {{this}}), '1970-01-01'){% endif %}
    qualify row_number() over (partition by FIELD_ID, VALUE_ID order by _FILEDATE desc) = 1
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        FIELD_ID,
        VALUE_ID,
        POSITION,
        IS_ENABLED,
        IS_DEFAULT,
        VALUE,
    from source_data
),

type_data as (
    select 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        FIELD_ID,
        VALUE_ID,
        POSITION,
        IS_ENABLED,
        IS_DEFAULT,
        VALUE,
    from transform_data
)

select * from type_data
