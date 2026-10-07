/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.13"
*************/

{{ config(
      materialized='view',
      alias='BAANFINANCEGENERALLEDGER_INTEGRATIONLINESCREDIT',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        AMOUNT,
        AMOUNTINHOMECURRENCY1,
        AMOUNTINHOMECURRENCY2,
        AMOUNTINHOMECURRENCY3,
        COSTPRICECOMPONENT,
        CURRENCY,
        CURRENCYRATE1,
        CURRENCYRATE2,
        CURRENCYRATE3,
        DEBITCREDITDESCRIPTION,
        DEBITCREDITID,
        DEPARTMENT,
        DIMENSIONCODE1,
        DIMENSIONCODE2,
        DIMENSIONCODE3,
        DIMENSIONCODE4,
        DIMENSIONCODE5,
        ENTERPRISEUNIT,
        EXCHANGERATETYPE,
        FINANCIALTRANSACTIONDESCRIPTION,
        FINANCIALTRANSACTIONID,
        FISCALPERIOD,
        FISCALYEAR,
        ITEM,
        LEDGERACCOUNT,
        NUMBEROFUNITS,
        ORIGINALCOMPANY,
        RATEDATE,
        RATEFACTOR1,
        RATEFACTOR2,
        RATEFACTOR3,
        REPORTINGPERIOD,
        REPORTINGYEAR,
        SEQUENCENUMBER,
        TRANSACTIONDATE,
        TRANSACTIONORIGINDESCRIPTION,
        TRANSACTIONORIGINID,
        UNIT,
        WAREHOUSE
    from {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_INTEGRATIONLINESCREDIT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data