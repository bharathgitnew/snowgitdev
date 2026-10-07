/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.11"
*************/

{{ config(
      materialized='view',
      alias='BAANFINANCEGENERALLEDGER_BAAN_PROCITAPPROVEDINVOICESINFORMATION',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        AMOUNTINHOMECURRENCY,
        COMPANY,
        COMPANYCODE,
        CREATIONDATE,
        CURRENCYCODE,
        DIMENSION1,
        DIMENSION2,
        DIMENSION3,
        DIMENSION4,
        DIMENSION5,
        DIN_HASH_,
        DOCUMENTDATE,
        DOCUMENTNUMBER,
        DUEDATE,
        FISCALPERIOD,
        FISCALYEAR,
        FREIGHT,
        HEADER,
        INVOICEAMOUNT,
        INVOICECREATEDBY,
        INVOICEDATE,
        INVOICELINES,
        INVOICENUMBER,
        LEDGERACCOUNT,
        LINE,
        LINENUMBER,
        PONUMBER,
        POSITIONNUMBER,
        POSTINGDATE,
        PURCHASEINVOICESBYBATCH,
        SUPPLIER,
        TAXAMOUNT,
        TERMSOFPAYMENTS,
        TEXT,
        TOTALAMOUNT,
        TRANSACTIONTYPECODE,
        UNMATCHEDLEDGERACC
    from {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_BAAN_PROCITAPPROVEDINVOICESINFORMATION') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data