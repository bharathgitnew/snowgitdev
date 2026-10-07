{{ config(
        materialized='view',
         alias='MATERIAL_VALUATION_HISTORY',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
        MATERIAL_NUMBER,
        VALUATION_AREA,
        VALUATION_TYPE,
        FISCAL_YEAR_OF_CURRENT_PERIOD,
        CURRENT_PERIOD,
        TOTAL_VALUATED_STOCK,
        VALUE_OF_TOTAL_VALUATED_STOCK,
        PRICE_CONTROL_INDICATOR,
        MOVING_AVERAGE_PRICE_PERIODIC_UNIT_PRICE,
        STANDARD_PRICE,
        PRICE_UNIT,
        VALUATION_CLASS,
        VALUE_BASED_ON_MOVING_AVERAGE_PRICE,
        VALUE_OF_TOTAL_VALUATED_STOCK_AT_SALES_PRICE,
        _CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__MATERIAL_VALUATION_HISTORY') }}

),

transform_data as (
    select
        *
    from source_data
)

select * from transform_data