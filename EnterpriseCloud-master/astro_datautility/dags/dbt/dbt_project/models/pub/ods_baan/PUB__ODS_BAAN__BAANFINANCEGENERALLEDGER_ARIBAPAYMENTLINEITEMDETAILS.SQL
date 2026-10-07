/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.11"
*************/

{{ config(
      materialized='view',
      alias='BAANFINANCEGENERALLEDGER_ARIBAPAYMENTLINEITEMDETAILS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ADJUSTEDCOSTITEM,
        AMOUNT,
        CONVERSIONFACTOR,
        DIMENSION5,
        ISCOMPOSITEDESCRIPTION,
        ISCOMPOSITEID,
        ITEMTEXT,
        LINETYPECATERY_LCAT,
        LINETYPECATERY_LTYP,
        MASTERAGREEMENTNAME,
        NUMBERINCOLLECTION,
        ORDER_,
        ORDER_LINES,
        PAYMENTID,
        POLINENUMBER,
        PONUMBER,
        PORECEIVINGTYPE,
        POSITION,
        PRICEBASISQUANTITY,
        PRICEQUANTITY,
        PRICEQUANTITYUOM,
        PROCESSDATE,
        PURCHASEORDERPOS,
        QUANTITY,
        REFERENCEINVDOCUMENT,
        SAPPARENTPOITEM,
        SAPPOITEM,
        SEQ,
        SERVICELINENUMBER,
        SERVICESHEETID,
        STATUSDESCRIPTION,
        STATUSID,
        TAXCODE,
        UNITOFMEASURE
    from {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_ARIBAPAYMENTLINEITEMDETAILS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data