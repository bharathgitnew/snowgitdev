{{ config(
    alias = 'ATLAN_TABLES',
    materialized = 'tel_incremental',
    incremental_strategy = 'merge',
    unique_key = ['GUID'],
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        JSONFIELD:guid::string as GUID,
        JSONFIELD:display_text::string as DISPLAY_TEXT,
        parse_json(JSONFIELD:atlan_tags) as ATLAN_TAGS,
        parse_json(JSONFIELD:classification_names) as CLASSIFICATION_NAMES,
        JSONFIELD:create_time::int as CREATE_TIME,
        JSONFIELD:created_by::string as CREATED_BY,
        JSONFIELD:is_incomplete::boolean as IS_INCOMPLETE,
        parse_json(JSONFIELD:labels) as LABELS,
        parse_json(JSONFIELD:meaning_names) as MEANING_NAMES,
        parse_json(JSONFIELD:meanings) as MEANINGS,
        JSONFIELD:status::string as STATUS,
        JSONFIELD:type_name::string as TYPE_NAME,
        JSONFIELD:update_time::int as UPDATE_TIME,
        JSONFIELD:updated_by::string as UPDATED_BY,
        parse_json(JSONFIELD:attributes) as ATTRIBUTES,
    from {{ source('ATLAN', 'TABLES') }}
    qualify row_number() over(partition by GUID order by UPDATE_TIME desc, _FILEDATE desc) = 1
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        GUID,
        DISPLAY_TEXT,
        ATLAN_TAGS,
        CLASSIFICATION_NAMES,
        CREATE_TIME,
        CREATED_BY,
        IS_INCOMPLETE,
        LABELS,
        MEANING_NAMES,
        MEANINGS,
        STATUS,
        TYPE_NAME,
        UPDATE_TIME,
        UPDATED_BY,
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
        GUID,
        DISPLAY_TEXT,
        ATLAN_TAGS,
        CLASSIFICATION_NAMES,
        CREATE_TIME,
        CREATED_BY,
        IS_INCOMPLETE,
        LABELS,
        MEANING_NAMES,
        MEANINGS,
        STATUS,
        TYPE_NAME,
        UPDATE_TIME,
        UPDATED_BY,
        ATTRIBUTES,
    from transform_data
)

select * from type_data
