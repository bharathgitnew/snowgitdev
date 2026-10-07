{{ config(
      materialized='view',
      alias='TEA_BAAN_SALES_SERVICES_ORDERS_BY_MONTH_CUSTOMER',
      transient=false
) }}

with source_data as (
    SELECT
        ITEM
        ,PERIOD
        ,SOLD_TO_BP
        ,QTY
    from {{ ref('COMMON__BAAN__TEA_BAAN_SALES_SERVICES_ORDERS_BY_MONTH_CUSTOMER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data