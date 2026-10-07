{{ config(
      materialized='view',
      alias='SPARES_REVENUE',
      transient=false,
      enabled=true
) }}

with source_data as (
    select
        *
    FROM {{ ref('COMMON__REPORTS__DAILY_ACTUALS_SALES_LINE') }} 

),

transform_data AS
(
    select * from source_data
)

    select * from transform_data