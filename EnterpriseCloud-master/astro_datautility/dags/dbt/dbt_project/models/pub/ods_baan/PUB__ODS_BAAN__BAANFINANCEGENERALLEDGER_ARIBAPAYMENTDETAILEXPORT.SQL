/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.11"
*************/

{{ config(
      materialized='view',
      alias='BAANFINANCEGENERALLEDGER_ARIBAPAYMENTDETAILEXPORT',
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
        COMPANY,
        CONVERSIONFACTOR,
        COSTCENTER,
        DIMENSION2,
        DIMENSION3,
        DIMENSION4,
        DIMENSION5,
        DRCR,
        HEADERLINELEVELDESCRIPTION,
        HEADERLINELEVELID,
        INTERNALORDER,
        ISCOMPOSITEDESCRIPTION,
        ISCOMPOSITEID,
        ITEMTEXT,
        LEDGERACCOUNT,
        LINETYPECATERY_CATE,
        LINETYPECATERY_LTYP,
        MASTERAGREEMENTNAME,
        NUMBERINCOLLECTION_COLL,
        NUMBERINCOLLECTION_FLAG,
        ORDER_,
        ORDER_UNIQUENAME,
        PAYMENTID,
        POSITION,
        PRICEBASISQUANTITY,
        PRICEQUANTITY,
        PRICEQUANTITYUOM,
        PROCESSDATE,
        PURCHASEORDERPOS,
        SEQUENCENUMBER,
        SHIPTO,
        STATUSDESCRIPTION,
        STATUSID,
        TARGETCOMPANY,
        TAXACCCOUNTKEY,
        TAXCODE,
        WBSELEMENT
    from {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_ARIBAPAYMENTDETAILEXPORT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data