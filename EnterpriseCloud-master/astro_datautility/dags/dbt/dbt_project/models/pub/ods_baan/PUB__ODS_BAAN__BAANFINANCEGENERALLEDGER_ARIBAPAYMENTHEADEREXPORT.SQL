/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.11"
*************/

{{ config(
      materialized='view',
      alias='BAANFINANCEGENERALLEDGER_ARIBAPAYMENTHEADEREXPORT',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ADJUSTEDTOTALCOST,
        AMOUNTCURRENCY,
        APPROVALDATE,
        BASELINEDATE,
        BASELINEDATEINREQUESTERTIMEZONE,
        BATCHNUMBER,
        COMPANYCODE,
        DIN_HASH_,
        DIRECTACTIONURL,
        DOCUMENTNUMBER,
        DUEDATE,
        EFFECTIVEDATEINREQUESTERTIMEZONE,
        FILENAME,
        FISCALPERIOD,
        FISCALYEAR,
        GROSSAMOUNT,
        INVOICEDATE,
        INVOICENUMBER,
        INVOICEPURPOSE,
        INVOICETOCREDITNUMBER,
        ITEMTEXT,
        PAYMENTID,
        PAYMENTMETHOD,
        PAYMENTTERMSEFFECTIVEDATE,
        PRICEADJUSTMENTINVOICEDESCRIPTION,
        PRICEADJUSTMENTINVOICEID,
        PROCESSDATE,
        REPROCESSDATE,
        REPROCESSEDBY,
        SAPINVOICEIND,
        SEQUENCENO,
        STATUSDESCRIPTION,
        STATUSID,
        SUPPLIERLOCATION,
        TAXACCURALAMOUNT,
        TAXPERIOD,
        TAXYEAR,
        TERMSOFPAYMENT,
        TRANSACTIONTYPE
    from {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_ARIBAPAYMENTHEADEREXPORT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data