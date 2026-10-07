{{ config(
        materialized='view',
         alias='PUBLIC_HOLIDAY_CALENDAR',
         transient=false
) }}

with source_data as (
    select
        _CAPTUREDATETIME,
        IDENT,
        DATUM,
        FTGID,
        GARANT
    from {{ ref('ODS__SAPO__PUBLIC_HOLIDAY_CALENDAR') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data