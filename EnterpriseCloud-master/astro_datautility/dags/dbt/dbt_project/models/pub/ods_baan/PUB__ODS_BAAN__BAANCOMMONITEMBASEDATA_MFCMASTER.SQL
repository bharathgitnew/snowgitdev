/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.00"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONITEMBASEDATA_MFCMASTER',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        BAAN4_CUSTOMERPRICELIST,
        BAAN4_INTELPRICELIST,
        BAAN4_ITEMMASTERPRICE,
        BAAN4_ITEMPRICELIST,
        BAAN4_SALESORDERPRICE,
        BAAN4_SALESQUOTEPRICE,
        BAAN4_SERVICEORDERPRICE,
        CURRENTITEMMASTERPRICE,
        INTELFLAGDESCRIPTION,
        INTELFLAGID,
        INTELPRICEBOOKPRICE,
        ITEM,
        LOWESTPRICE,
        SALESCONTRACT,
        SALESCONTRACTLOWPRICE,
        SALESORDER,
        SALESORDERLOWPRICE,
        SALESPRICEBOOKLOWPRICE,
        SALESQUOTATION,
        SALESQUOTELOWPRICE,
        SERVICECONTRACT,
        SERVICECONTRACTLOWPRICE,
        SERVICEORDER,
        SERVICEORDERLOWPRICE,
        SERVICEQUOTATION,
        SERVICEQUOTELOWPRICE,
        UPDATEDATE
    from {{ ref('ODS__BAAN__BAANCOMMONITEMBASEDATA_MFCMASTER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data