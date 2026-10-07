/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.12"
*************/

{{ config(
      materialized='view',
      alias='BAANFINANCEGENERALLEDGER_BAAN_PROCITRECEIPTSINFORMATION',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        AMOUNTINHOMECURRENCY,
        COMPANYNUMBER,
        COST_PERCENT_PRICE,
        CURRENCYCODE,
        DIMENSION1,
        DIMENSION2,
        DIMENSION3,
        DIMENSION4,
        DIMENSION5,
        DOCUMENTDATE,
        DOCUMENTNUMBER,
        FISCALPERIOD,
        FISCALYEAR,
        ITEM,
        LEDGERACCOUNT,
        LINENUMBER,
        POSITIONNUMBER,
        PURCHASEINVOICESBYBATCH,
        PURCHASEORDER,
        RECEIPTDATE,
        RECEIPTDETAILS,
        RECEIVEDQUANTITY,
        RECEIVERUSERID,
        REFERENCENUMBER,
        REQUESTORUSERID,
        SUPPLIER,
        TOTALCOST,
        TRANSACTIONTYPECODE,
        UNIT,
        UNMATCHEDLEDGERACC
    from {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_BAAN_PROCITRECEIPTSINFORMATION') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data