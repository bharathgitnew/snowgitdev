/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.12"
*************/

{{ config(
      materialized='view',
      alias='BAANFINANCEGENERALLEDGER_BAAN_PROCITREGISTEREDINVOICESINFORMATION',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        AMOUNTINHOMECURRENCY,
        COMPANY,
        CREATIONDATE,
        CURRENCYCODE,
        DIN_HASH_,
        DOCUMENTDATE,
        DOCUMENTNUMBER,
        DUEDATE,
        FISCALPERIOD,
        FISCALYEAR,
        FREI,
        INVOICEAMOUNT,
        INVOICECREATEDBY,
        INVOICEDATE,
        INVOICELINES,
        INVOICENUMBER,
        LINENUMBER,
        PONUMBER,
        POSTINGDATE,
        PURCHASEINVOICESBYBATCH,
        SUPPLIER,
        TAXAMOUNT,
        TERMSOFPAYMENT,
        TEXT,
        TRANSACTIONTYPE
    from {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_BAAN_PROCITREGISTEREDINVOICESINFORMATION') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data