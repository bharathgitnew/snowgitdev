/************
Model file generated from dbtGeneratePubViews: 12.22.2022.10.52.54"
*************/

{{ config(
      materialized='view',
      alias='PNL_ACCOUNTS_SALES_CATEGORY',
      transient=false
) }}

with source_data as (
    SELECT
        COMPANY_CODE,
        FISCAL_YEAR,
        ACCOUNTING_DOCUMENT_NUMBER,
        ACDOCA_BUSINESS_TRANSACTION_TYPE,
        LEDGER_IN_GENERAL_LEDGER_ACCOUNTING,
        NAME_1,
        ACCOUNT_NUMBER,
        SALES_CATEGORY,
        SALES_DOCUMENT,
        SALES_DOCUMENT_ITEM
    from {{ ref('COMMON__SAPH__PNL_ACCOUNTS_SALES_CATEGORY') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data