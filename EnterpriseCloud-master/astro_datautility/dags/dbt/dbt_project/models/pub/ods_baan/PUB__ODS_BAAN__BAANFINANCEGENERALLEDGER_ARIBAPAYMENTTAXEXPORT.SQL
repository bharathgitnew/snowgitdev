/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.11"
*************/

{{ config(
      materialized='view',
      alias='BAANFINANCEGENERALLEDGER_ARIBAPAYMENTTAXEXPORT',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ACCOUNTINSTRUCTION,
        ACCRUALDESCRIPTION,
        ACCRUALID,
        ACCURALTAXAMOUNT,
        BUYERTAXREGISTRATIONNUMBER,
        DEDUCTIBLEDESCRIPTION,
        DEDUCTIBLEID,
        DRCR,
        EXPECTEDTAXRATE,
        INVOICECITATION,
        INVOICELINENUMBER,
        ITEMTEXT,
        PAYMENTID,
        POSITIONNUMBER,
        PROCESSDATE,
        REFERENCELINENUMBER,
        SELLERTAXREGISTRATIONNUMBER,
        SEQUENCE,
        STATUSDESCRIPTION,
        STATUSID,
        TAXABLEAMOUNT,
        TAXACCOUNTKEY,
        TAXAMOUNTINERPPRECISION,
        TAXAMOUNTINPAYMENTCURRENCY,
        TAXAUTHORITY,
        TAXCODE
    from {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_ARIBAPAYMENTTAXEXPORT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data