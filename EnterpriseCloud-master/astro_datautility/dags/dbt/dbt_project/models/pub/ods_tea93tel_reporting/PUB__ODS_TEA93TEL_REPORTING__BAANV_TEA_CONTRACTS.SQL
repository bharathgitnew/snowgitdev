/************
Model file generated from dbtGeneratePubViews: 10.03.2022.08.31.46"
*************/

{{ config(
      materialized='view',
      alias='BAANV_TEA_CONTRACTS',
      transient=false
) }}

with source_data as (
    SELECT
        CONTRACT_NO,
        CONTRACT_DESCRIPTION,
        SEARCH_ARGUMENT,
        INVOICETO_BPID,
        INVOICETO_BP,
        CONFIGURATION,
        CUSTOMER_PO_NO,
        CONTRACT_STATUS,
        EFFECTIVE_DATE,
        EXPIRATION_DATE,
        SERVICE_TYPE,
        COST_TYPE,
        CONTRACT_AMT,
        CONTRACT_TYPE,
        CONTRACT_TYPE_DESCRIPTION,
        RENEWAL_TYPE,
        CURRENCY,
        SALES_PRICE_LIST,
        TERMS_OF_PAYMENT,
        LATE_PAYMENT_SURCHARGE,
        TAX_CODE,
        REFERENCE_B,
        COVERED_TIME,
        TERM_ID,
        TERM_ID_TYPE,
        COST_COV_METHOD,
        COST_COV_CEILING,
        COST_COV_DISC_PCT,
        CHANGE_EFFECTIVE_DATE,
        SALES_REP,
        SERVICE_CENTER,
        BACKFILL,
        CANCELLED_DATE
    from {{ ref('ODS__TEA93TEL_REPORTING__BAANV_TEA_CONTRACTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data