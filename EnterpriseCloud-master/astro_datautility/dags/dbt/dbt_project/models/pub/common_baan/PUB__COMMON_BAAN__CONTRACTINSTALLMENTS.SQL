/************
Model file generated from dbtGeneratePubViews: 04.08.2022.10.56.58"
*************/

{{ config(
      materialized='view',
      alias='CONTRACTINSTALLMENTS',
      transient=false
) }}

with source_data as (
    SELECT
        CONTRACT_NUMBER,
        GROSS_AMOUNT,
        CONFIGURATION,
        CONTRACT_AMT,
        CONTRACT_DESCRIPTION,
        INSTALLMENT_AMOUNT,
        STATUS,
        INVOICE_NUMBER,
        INVOICE_DATE,
        INSTALLMENT_NUMBER,
        DISCOUNT,
        DISCOUNT_AMOUNT,
        NET_INSTALLMENT_AMOUNT,
        WARRANTY_CREDIT,
        FORECAST_COST_PERCENTAGE,
        NUMBER_OF_PERIODS,
        TRANSACTION_TYPE,
        COMPANY,
        TAX_AMOUNT,
        PLANNED_INVOICE_DATE,
        CUSTOMER_PO_LINE
    from {{ ref('COMMON__BAAN__CONTRACTINSTALLMENTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data