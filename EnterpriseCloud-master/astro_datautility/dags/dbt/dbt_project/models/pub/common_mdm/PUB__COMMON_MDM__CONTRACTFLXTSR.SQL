/************
Model file generated from dbtGeneratePubViews: 04.05.2022.12.11.10"
*************/

{{ config(
      materialized='view',
      alias='CONTRACTFLXTSR',
      transient=false
) }}

with source_data as (
    SELECT
        REVREC_MONTH,
        REVREC_DATE,
        CONTRACT_NUMBER,
        SO_NUMBER,
        ACTUAL_TSR_HOURS,
        ACTUAL_TSR_AMOUNT,
        FINANCE_TSR_HOURS,
        FINANCE_REVENUE_AMOUNT,
        CUSTOMER,
        BU,
        OFFICE,
        CUSTOMER_CODE,
        OFFICE_CODE,
        BU_CODE,
        PRODUCT_TYPE_CODE,
        SERIAL_NUMBER,
        SOLD_TO_CODE,
        TSR_CONSUMED_REMAINING_HOURS,
        COMMENTS,
        MODIFIED,
        MODIFIED_BY
    from {{ ref('COMMON__MDM__CONTRACTFLXTSR') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data