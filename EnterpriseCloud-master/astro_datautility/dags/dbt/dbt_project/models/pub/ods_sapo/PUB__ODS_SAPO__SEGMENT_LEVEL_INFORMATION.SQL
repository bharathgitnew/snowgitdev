{{ config(
        materialized='view',
         alias='SEGMENT_LEVEL_INFORMATION',
         transient=false
) }}

with source_data as (
    select
* exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__SAPO__SEGMENT_LEVEL_INFORMATION') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data