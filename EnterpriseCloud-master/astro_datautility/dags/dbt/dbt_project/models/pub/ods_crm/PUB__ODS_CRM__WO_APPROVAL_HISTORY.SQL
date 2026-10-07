{{ config(
        alias = 'WO_APPROVAL_HISTORY',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__WO_APPROVAL_HISTORY') }} 
)

select * from source_data