{{ config(
        alias = 'SM_FAB_LINE',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__SM_FAB_LINE') }} 
)

select * from source_data