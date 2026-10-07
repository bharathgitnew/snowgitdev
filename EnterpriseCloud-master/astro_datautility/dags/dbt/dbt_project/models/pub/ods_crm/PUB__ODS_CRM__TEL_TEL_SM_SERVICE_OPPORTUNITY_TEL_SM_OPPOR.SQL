{{ config(
        alias = 'TEL_TEL_SM_SERVICE_OPPORTUNITY_TEL_SM_OPPOR',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__TEL_TEL_SM_SERVICE_OPPORTUNITY_TEL_SM_OPPOR') }} 
)

select * from source_data