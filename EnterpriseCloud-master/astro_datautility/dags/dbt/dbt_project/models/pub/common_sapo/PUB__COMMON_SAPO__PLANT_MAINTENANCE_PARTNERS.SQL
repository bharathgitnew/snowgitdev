{{ config(
        materialized='view',
         alias='PLANT_MAINTENANCE_PARTNERS',
         transient=false
) }}

with source_data as (
    select
* exclude(AUDIT_LOG_ID,_ROW_HASH)
    from {{ ref('COMMON__SAPO__PLANT_MAINTENANCE_PARTNERS') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data