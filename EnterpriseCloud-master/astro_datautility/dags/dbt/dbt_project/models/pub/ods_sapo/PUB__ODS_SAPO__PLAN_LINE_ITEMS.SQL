{{ config(
        materialized='view',
         alias='PLAN_LINE_ITEMS',
         transient=false
) }}

with source_data as (
    select
* exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__SAPO__PLAN_LINE_ITEMS') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data