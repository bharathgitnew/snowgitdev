{{ config(
        materialized='view',
         alias='PUBLIC_HOLIDAY_TEXTS',
         transient=false
) }}

with source_data as (
    select
        _CAPTUREDATETIME,
         FTGID,
        SPRAS,
        LTEXT,
        KTEXT
    from {{ ref('ODS__SAPO__PUBLIC_HOLIDAY_TEXTS') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data