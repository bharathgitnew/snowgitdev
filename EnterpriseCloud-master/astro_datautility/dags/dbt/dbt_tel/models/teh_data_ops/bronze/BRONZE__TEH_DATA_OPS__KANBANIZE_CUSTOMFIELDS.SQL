
{{ config(
    alias = 'KANBANIZE_CUSTOMFIELDS',
    materialized = 'tel_incremental',
    incremental_strategy = 'merge',
    unique_key = ['FIELD_ID'],
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        JSONFIELD:field_id::STRING as FIELD_ID,
        JSONFIELD:name::STRING as NAME,
        JSONFIELD:color::STRING as COLOR,
        JSONFIELD:is_immutable::STRING as IS_IMMUTABLE,
        JSONFIELD:is_always_present::STRING as IS_ALWAYS_PRESENT,
        JSONFIELD:all_properties_are_locked::STRING as ALL_PROPERTIES_ARE_LOCKED,
        JSONFIELD:availability::STRING as AVAILABILITY,
        JSONFIELD:is_enabled::STRING as IS_ENABLED,
        JSONFIELD:display_width::STRING as DISPLAY_WIDTH,
        JSONFIELD:min_number_of_values::STRING as MIN_NUMBER_OF_VALUES,
        JSONFIELD:max_number_of_values::STRING as MAX_NUMBER_OF_VALUES,
        JSONFIELD:allow_other_value::STRING as ALLOW_OTHER_VALUE,
        JSONFIELD:allowed_values_are_locked::STRING as ALLOWED_VALUES_ARE_LOCKED,
        JSONFIELD:type::STRING as TYPE,
    from {{ source('KANBANIZE', 'CUSTOMFIELDS') }} 
    {% if is_tel_incremental() %}where _FILEDATE > ifnull((select max(_FILEDATE) from {{this}}), '1970-01-01'){% endif %}
    qualify row_number() over (partition by FIELD_ID order by _FILEDATE desc) = 1
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        FIELD_ID,
        NAME,
        COLOR,
        IS_IMMUTABLE,
        IS_ALWAYS_PRESENT,
        ALL_PROPERTIES_ARE_LOCKED,
        AVAILABILITY,
        IS_ENABLED,
        DISPLAY_WIDTH,
        MIN_NUMBER_OF_VALUES,
        MAX_NUMBER_OF_VALUES,
        ALLOW_OTHER_VALUE,
        ALLOWED_VALUES_ARE_LOCKED,
        TYPE,
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
        NAME,
        COLOR,
        IS_IMMUTABLE,
        IS_ALWAYS_PRESENT,
        ALL_PROPERTIES_ARE_LOCKED,
        AVAILABILITY,
        IS_ENABLED,
        DISPLAY_WIDTH,
        MIN_NUMBER_OF_VALUES,
        MAX_NUMBER_OF_VALUES,
        ALLOW_OTHER_VALUE,
        ALLOWED_VALUES_ARE_LOCKED,
        TYPE,
    from transform_data
)

select * from type_data
