{{ config(
        alias = 'MSDYN_BPF_BAA0A411A239410CB8BDED8B5FDD88E3',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__MSDYN_BPF_BAA0A411A239410CB8BDED8B5FDD88E3') }} 
)

select * from source_data