/************
Model file generated from dbtGeneratePubViews: 10.12.2022.17.09.22"
*************/

{{ config(
      materialized='view',
      alias='BAANV_ADMIN_BUSINESS_PARTNERS',
      transient=false
) }}

with source_data as (
    SELECT
        SOURCE,
        BPID,
        COMPANY,
        BP_NAME,
        INVOICE_TO_ROLE,
        SHIP_TO_ROLE,
        SOLD_TO_ROLE,
        PAY_BY_ROLE,
        INVOICE_FROM_ROLE,
        TERMS_OF_PAYMENT,
        PAYMENT_METHOD,
        FINANCIAL_SUPPLIER_GROUP,
        CURRENCY,
        SHIP_FROM_ROLE,
        BUY_FROM_BY_ROLE,
        PAY_TO_ROLE
    from {{ ref('ODS__LEGACY93__BAANV_ADMIN_BUSINESS_PARTNERS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data