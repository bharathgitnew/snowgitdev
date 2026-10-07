{{ config(
        alias = 'MSDYN_WORKORDERSERVICE',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__MSDYN_WORKORDERSERVICE') }} 
)

select * from source_data