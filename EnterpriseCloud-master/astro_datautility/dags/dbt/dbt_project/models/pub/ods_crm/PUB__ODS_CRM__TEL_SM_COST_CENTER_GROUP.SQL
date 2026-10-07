{{ config(
        alias = 'TEL_SM_COST_CENTER_GROUP',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__TEL_SM_COST_CENTER_GROUP') }} 
)

select * from source_data