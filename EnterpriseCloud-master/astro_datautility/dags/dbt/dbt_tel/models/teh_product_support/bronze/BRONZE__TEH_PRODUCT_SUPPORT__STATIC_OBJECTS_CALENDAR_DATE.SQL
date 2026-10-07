{{ config(
        alias='STATIC_OBJECTS_CALENDAR_DATE',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
    select
       *
    from {{ source('STATIC_OBJECTS', 'CALENDAR_DATE') }} 
),

transform_data as (
    select 
       *
    from source_data
),

type_data as (
    select 
       *
    from transform_data
)

select * from type_data