{{ config(
      materialized='view',
      alias='FINALIZEDTRANSACTIONS',
      transient=false
) }}

with source_data as (
    SELECT
        AMOUNT,
        AMOUNT_IN_HC,
        BACKGROUND_SEQUENCE_NO,
        BATCH,
        BUSINESS_PARTNER_ID,
        CONTROL_ACCOUNT,
        COUNTRY,
        CURRENCY,
        DC,
        DC_DESC,
        DELETED,
        DIMENSION_1,
        DIMENSION_2,
        DIMENSION_3,
        DIMENSION_4,
        DIMENSION_5,
        DIMENSION_TYPE_1,
        DIMENSION_TYPE_2,
        DIMENSION_TYPE_3,
        DIMENSION_TYPE_4,
        DIMENSION_TYPE_5,
        DOCUMENT,
        DOC_DATE,
        FINALIZATION_DATE,
        FINALIZATION_RUN_NO,
        FINALIZATION_TIME,
        FINANCIAL_PERIOD,
        FISCAL_YEAR,
        INTEGRATION_TRANSACTION,
        INVOICE_CORRECTION,
        LAST_MODIFIED_BY,
        LEDGER_ACC,
        LEDGER_ACC_DESC,
        LINE,
        ORIGINAL_COMPANY,
        ORIGINAL_DOCUMENT_NO,
        ORIGINAL_TRANSACTION_TYPE,
        PERIOD_BEGINING,
        QUANTITY_1,
        QUANTITY_2,
        RATE,
        RATE_FACTOR,
        REFERENCE,
        REPORTING_PERIOD,
        REPORTING_YEAR,
        SEQUENCE_NUMBER,
        STANDING_ORDER,
        STANDING_ORDER_SEQUENCE_NO,
        TAX_AMOUNT,
        TAX_AMOUNT_HC,
        TAX_CODE,
        TAX_LEDGER_AC,
        TAX_PERIOD,
        TAX_TYPE,
        TAX_YEAR,
        TRANSACTION_CATEGORY,
        TRANSACTION_TEXT,
        TRANSACTION_TYPE,
        TRANS_TYPE_CORRECTION,
        TYPE_OF_CASH_TRANSACTION,
        TYPE_OF_TRANSACTION        
    from {{ ref('COMMON__BAAN__FINALIZEDTRANSACTIONS') }}
),

transform_data AS
(
    select * from source_data
)

select * from transform_data