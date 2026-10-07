{{ config(
        alias = 'TEL_OPPORTUNITY_TEL_SM_OPPORTUNITY_GROUP',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__TEL_OPPORTUNITY_TEL_SM_OPPORTUNITY_GROUP') }} 
)

select * from source_data