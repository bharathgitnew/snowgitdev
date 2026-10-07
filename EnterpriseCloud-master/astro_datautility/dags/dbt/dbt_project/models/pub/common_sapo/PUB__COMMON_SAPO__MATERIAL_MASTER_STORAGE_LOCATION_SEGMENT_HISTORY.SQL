{{ config(
        materialized='view',
         alias='MATERIAL_MASTER_STORAGE_LOCATION_SEGMENT_HISTORY',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
        MATERIAL_NUMBER,
        PLANT,
        STORAGE_LOCATION,
        FISCAL_YEAR_OF_CURRENT_PERIOD,
        CURRENT_PERIOD,
        VALUATED_UNRESTRICTED_USE_STOCK,
        STOCK_IN_TRANSFER,
        STOCK_IN_QUALITY_INSPECTION,
        TOTAL_STOCK_OF_ALL_RESTRICTED_BATCHES,
        BLOCKED_STOCK,
        BLOCKED_STOCK_RETURNS,
        STOCK_VALUE_OF_A_VALUE_ONLY_MATERIAL_AT_SALES_PRICE,
        SALES_VALUE_IN_STOCK_TRANSFER,
        _CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__MATERIAL_MASTER_STORAGE_LOCATION_SEGMENT_HISTORY') }}

),

transform_data as (
    select
        *
    from source_data
)

select * from transform_data