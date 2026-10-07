{{ config(
        materialized='view',
         alias='BOM_HEADER',
         transient=false
) }}

with source_data as (
    select
* exclude(_AUDIT_LOG_ID,_ROW_HASH)
    from {{ ref('COMMON__SAPO__BOM_HEADER') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data