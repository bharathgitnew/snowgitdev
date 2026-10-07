{{ config(
        alias = 'TEL_SM_LEAD_TIME',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__TEL_SM_LEAD_TIME') }} 
)

select * from source_data