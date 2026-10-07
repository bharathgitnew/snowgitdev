{{ config(
        alias = 'MSDYN_INCIDENTTYPEPRODUCT',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__MSDYN_INCIDENTTYPEPRODUCT') }} 
)

select * from source_data