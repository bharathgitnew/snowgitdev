{{ config(
      materialized='view',
      alias='SUPPLIERS',
      transient=false
) }}

with source_data as (
    SELECT
      SUPPLIER_CODE,
      SUPPLIER,
      ADDRESS_NAME,
      ADDRESS,
      CITY,
      STATE_PROVINCE,
      POSTAL_CODE,
      COUNTRY,
      TELEPHONE,
      FAX,
      TAX_NUMBER,
      VERIFICATION_DATE,
      CURRENCY,
      TERMS_OF_PAYMENT,
      FINANCIAL_SUPPLIER_GROUP,
      SUPPLIER_STATUS,
      SHIP_FROM_DATA,
      LINE_OF_BUSINESS,
      PURCHASE_PRICE_LIST,
      PRICE_BOOK,
      SUPPLIER_NAME_1099,
      SUPPLIER_ADDRESS_CODE_1099,
      SUPPLIER_ADDRESS_1099,
      SUPPLIER_CITY_1099,
      SUPPLIER_POSTAL_CODE_1099,
      PAYEE_NAME_CONTROL,
      FOREIGN_ENTITY,
      INCOME_TAX_TYPE,
      ACCOUNT_NO_1099,
      TIN_2ND,
      REASON_FOR_PAYMENT,
      BUSINESS_PARTNER_TYPE,
      COMMODITY_CODE,
      SUB_COMMODITY_CODE,
      GENERAL_BP_STATUS
    from {{ ref('COMMON__BAAN__SUPPLIERS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data