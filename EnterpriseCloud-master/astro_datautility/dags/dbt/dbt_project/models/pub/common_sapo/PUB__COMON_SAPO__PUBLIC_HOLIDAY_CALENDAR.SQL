{{ config(
        materialized='view',
         alias='PUBLIC_HOLIDAY_CALENDAR',
         transient=false
) }}

with source_data as (
    select
        _CAPTUREDATETIME,
        PUBLIC_HOLIDAY_CALENDAR,
        DATE,
        PUBLIC_HOLIDAY_KEY,
        PUBLIC_HOLIDAY_GUARANTEED_FLAG
    from {{ ref('COMMON__SAPO__PUBLIC_HOLIDAY_CALENDAR') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data