{{ config(
        alias = 'MSDYN_INCIDENTTYPESSETUP',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__MSDYN_INCIDENTTYPESSETUP') }} 
)

select * from source_data