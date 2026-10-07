-- copied from COMMON__SHARED_DATASETS__CALENDAR_DATE
{{ config(
    alias = 'CALENDAR_DATE',
    materialized = 'tel_incremental',
    incremental_strategy = 'merge',
    unique_key = ['CALENDAR_DATE'],
) }}

with source_data as (
    select
        *
    from {{ source('STATIC_OBJECTS', 'CALENDAR_DATE') }} 
    where CALENDAR_DATE >= (select coalesce(max(CALENDAR_DATE), '1900-01-01') from {{ this }})
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        current_timestamp()::timestamp_ntz as _REFRESHDATE,
        *
    from source_data
),

type_data as (
    select 
        *
    from transform_data
)

select * from type_data
