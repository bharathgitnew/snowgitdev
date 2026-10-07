{{ config(
        alias = 'VALUATION_OF_SALESORDER_STOCK_HISTORY',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID,_ROW_HASH)
    from {{ ref('COMMON__REPORTS__VALUATION_OF_SALESORDER_STOCK_HISTORY') }} 
)

select * from source_data