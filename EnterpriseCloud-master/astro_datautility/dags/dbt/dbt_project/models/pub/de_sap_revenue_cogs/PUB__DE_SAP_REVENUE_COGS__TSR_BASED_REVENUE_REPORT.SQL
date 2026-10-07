{{ config(
        alias = 'TSR_BASED_REVENUE_REPORT',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__REPORTS__TSR_BASED_REVENUE_REPORT') }} 
)

select * from source_data