{{ config(
        alias = 'CNT_MSDYN_AGREEMENT_MSDYN_CUSTOMERASSET',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__CNT_MSDYN_AGREEMENT_MSDYN_CUSTOMERASSET') }} 
)

select * from source_data