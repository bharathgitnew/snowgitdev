/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.10"
*************/

{{ config(
      materialized='view',
      alias='BAANFINANCEGENERALLEDGER_ARIBAPAYMENTACCOUNTDETAILS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ADJUSTEDCOSTITEM,
        AMOUNT,
        ASSET,
        ASSETSUBNUMBER,
        COSTCENTER,
        INTERNALORDER,
        INVOICEDATE,
        LEDGERACCOUNT,
        LINETYPECATERY_LCAT,
        LINETYPECATERY_LTYP,
        NUMBERINCOLLECTION,
        OFFICEEXPORT,
        ORDER_,
        PAYMENTID,
        PONUMBER,
        PORECEIVINGTYPE,
        POSITION,
        PRICEQUANTITYUOM,
        PROCESSDATE,
        PROJECTEXPORT,
        QUANTITY,
        SEGMENTEXPORT,
        SEQUENCE,
        SERIALNUMBER,
        STATUSDESCRIPTION,
        STATUSID,
        TARGETCOMPANY,
        TAXCODE,
        UNITOFMEASURE,
        WBSELEMENT
    from {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_ARIBAPAYMENTACCOUNTDETAILS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data