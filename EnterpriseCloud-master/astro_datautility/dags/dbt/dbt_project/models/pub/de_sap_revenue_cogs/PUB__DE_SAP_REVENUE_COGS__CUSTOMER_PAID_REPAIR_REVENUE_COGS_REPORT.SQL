{{ config(
        alias = 'CUSTOMER_PAID_REPAIR_REVENUE_COGS_REPORT',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__REPORTS__CUSTOMER_PAID_REPAIR_REVENUE_COGS_REPORT') }} 
)

select * from source_data