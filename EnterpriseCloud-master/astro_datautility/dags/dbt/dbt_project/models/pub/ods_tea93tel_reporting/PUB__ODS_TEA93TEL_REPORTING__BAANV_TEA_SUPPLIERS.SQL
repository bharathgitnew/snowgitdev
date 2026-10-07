/************
Model file generated from dbtGeneratePubViews: 10.03.2022.08.31.45"
*************/

{{ config(
      materialized='view',
      alias='BAANV_TEA_SUPPLIERS',
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
        CURRENCY,
        TERMS_OF_PAYMENT,
        FINANCIAL_SUPPLIER_GROUP,
        SUPPLIER_STATUS,
        LINE_OF_BUSINESS_CODE,
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
        TAX_NUMBER,
        VERIFICATION_DATE,
        COMMODITY_CODE,
        SUB_COMMODITY_CODE,
        GENERAL_BP_STATUS
    from {{ ref('ODS__TEA93TEL_REPORTING__BAANV_TEA_SUPPLIERS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data