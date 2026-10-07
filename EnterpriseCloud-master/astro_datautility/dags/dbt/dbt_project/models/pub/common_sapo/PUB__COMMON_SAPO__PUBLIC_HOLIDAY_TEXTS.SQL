{{ config(
        materialized='view',
         alias='PUBLIC_HOLIDAY_TEXTS',
         transient=false
) }}

with source_data as (
    select
        _CAPTUREDATETIME,
        PUBLIC_HOLIDAY_KEY,
        LANGUAGE_KEY,
        LONG_TEXT,
        PUBLIC_HOLIDAYS_SHORT_TEXT
    from {{ ref('COMMON__SAPO__PUBLIC_HOLIDAY_TEXTS') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data