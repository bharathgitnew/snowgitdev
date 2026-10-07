{{ config(
        alias = 'TEL_SM_BULK_FCST',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__TEL_SM_BULK_FCST') }} 
)

select * from source_data