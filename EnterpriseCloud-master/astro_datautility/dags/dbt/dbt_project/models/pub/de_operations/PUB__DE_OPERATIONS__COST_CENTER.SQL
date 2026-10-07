{{ config(
        materialized='view',
        alias='COST_CENTER',
        transient=false    
) }}

with source_data as (
    select 
        * EXCLUDE(_AUDIT_LOG_ID,_ROW_HASH)
    from {{ ref('COMMON__SAPH__COST_CENTER') }} 
),
transform_data AS
(
    select * from source_data
)
select * from transform_data