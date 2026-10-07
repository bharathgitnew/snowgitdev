{{ config(
        materialized='view',
         alias='INDEPENDENT_REQUIREMENTS_DATA',
         transient=false
) }}

with source_data as (
    select
* exclude(_AUDIT_LOG_ID,_ROW_HASH)
    from {{ ref('ODS__SAPO__INDEPENDENT_REQUIREMENTS_DATA') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data