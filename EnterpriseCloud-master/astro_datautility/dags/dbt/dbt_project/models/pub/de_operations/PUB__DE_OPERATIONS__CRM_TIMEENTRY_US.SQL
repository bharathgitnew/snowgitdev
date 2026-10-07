{{ config(
        alias = 'CRM_TIMEENTRY_US',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__REPORTS__CRM_TIMEENTRY_US') }} 
)

select * from source_data