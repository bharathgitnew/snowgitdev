-- requested by Brandon for reconsiliation purposes 6/16/2025
{{ config(
      materialized='view',
      alias='RAW_FORECASTBUDGET',
      transient=false
) }}

with source_data as (
    SELECT
        ACCOUNT_NUMBER_EPBCS,
        SUBS,
        DEPARTMENT,
        SEGMENT,
        REGION,
        SALES_CATEGORY_EPBCS,
        CUSTOMER,
        MODEL,
        PROJECT,
        VERSION,
        SCENARIO,
        YEAR,
        PERIOD,
        CURRENCY,
        AMOUNT
    from {{ ref('ODS__FILE__FORECASTBUDGET_EPBCS') }} FORECASTBUDGET
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data