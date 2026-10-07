{{ config(
        materialized='view',
         alias='LEGAL_CONTROL_DESTINATION_COUNTRIES_FOR_LICENSE',
         transient=false
) }}

with source_data as (
    select
        _CAPTUREDATETIME,
        CLIENT,
        LEGAL_REGULATION_FOR_LEGAL_CONTROL,
        LICENSE_TYPE,
        COUNTRY_OF_DESTINATION,
        INTERNAL_LICENSE_NUMBER,
        IS_DELETED
    from {{ ref('COMMON__SAPO__LEGAL_CONTROL_DESTINATION_COUNTRIES_FOR_LICENSE') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data