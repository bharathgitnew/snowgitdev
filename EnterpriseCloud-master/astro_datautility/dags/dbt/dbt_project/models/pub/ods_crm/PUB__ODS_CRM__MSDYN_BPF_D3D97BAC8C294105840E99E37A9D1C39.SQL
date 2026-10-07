{{ config(
        alias = 'MSDYN_BPF_D3D97BAC8C294105840E99E37A9D1C39',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__MSDYN_BPF_D3D97BAC8C294105840E99E37A9D1C39') }} 
)

select * from source_data