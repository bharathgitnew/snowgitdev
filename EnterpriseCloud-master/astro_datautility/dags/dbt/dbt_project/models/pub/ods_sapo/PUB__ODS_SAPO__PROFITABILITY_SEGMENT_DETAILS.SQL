{{ config(
        materialized='view',
         alias='PROFITABILITY_SEGMENT_DETAILS',
         transient=false
) }}

with source_data as (
    select
* exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__SAPO__PROFITABILITY_SEGMENT_DETAILS') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data