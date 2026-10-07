/************
Model file generated from dbtGeneratePubViews: 10.03.2022.08.31.45"
*************/

{{ config(
      materialized='view',
      alias='BAANV_TEA_CUSTOMERS',
      transient=false
) }}

with source_data as (
    SELECT
        CUSTOMER_CODE,
        CUSTOMER,
        ADDRESS_NAME,
        ADDRESS,
        CITY,
        STATE_PROVINCE,
        POSTAL_CODE,
        COUNTRY,
        TELEPHONE,
        FAX,
        CURRENCY,
        TERMS_OF_DELIVERY,
        ORDER_DISCOUNT,
        LINE_OF_BUSINESS,
        OUR_SUPPLIER_NO,
        SALES_REPRESENTATIVE,
        DATE_INVOICED,
        EXTRA_DAYS,
        CUSTOMER_PRICE_LIST,
        CREDIT_LIMIT,
        GENERAL_BP_STATUS,
        INV_TO_BP_STATUS
    from {{ ref('ODS__TEA93TEL_REPORTING__BAANV_TEA_CUSTOMERS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data