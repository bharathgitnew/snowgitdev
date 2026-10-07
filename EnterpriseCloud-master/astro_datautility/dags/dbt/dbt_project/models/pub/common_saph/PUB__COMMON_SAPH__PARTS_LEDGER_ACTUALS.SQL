/************
Model file generated from dbtGeneratePubViews: 12.22.2022.10.52.54"
*************/

{{ config(
      materialized='view',
      alias='PARTS_LEDGER_ACTUALS',
      transient=false
) }}

with source_data as (
    SELECT
        LEDGER_IN_GENERAL_LEDGER_ACCOUNTING,
        COMPANY_CODE,
        FISCAL_YEAR,
        ACCOUNTING_DOCUMENT_NUMBER,
        SIX_CHARACTER_POSTING_ITEM_FOR_LEDGER,
        ACDOCA_REFERENCE_DOCUMENT_NUMBER,
        REFERENCE_DOCUMENT_LINE_ITEM,
        AMOUNT_IN_COMPANY_CODE_CURRENCY,
        ACDOCA_ASSIGNMENT_NUMBER,
        BILLING_TYPE,
        SALES_DOCUMENT,
        SALES_DOCUMENT_ITEM_POSNR,
        SALES_CATEGORY
    from {{ ref('COMMON__SAPH__PARTS_LEDGER_ACTUALS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data