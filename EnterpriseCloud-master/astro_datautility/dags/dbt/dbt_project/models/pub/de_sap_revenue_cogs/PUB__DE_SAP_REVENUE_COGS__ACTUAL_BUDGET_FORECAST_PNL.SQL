{{ config(
        alias = 'ACTUAL_BUDGET_FORECAST_PNL',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID)
    from {{ ref('COMMON__SAPH__ACTUAL_BUDGET_FORECAST_PNL') }} 
)

select * from source_data