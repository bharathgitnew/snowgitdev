{{ config(
        alias = 'SM_BULK_INFO',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__SM_BULK_INFO') }} 
)

select * from source_data