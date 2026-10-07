/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.25"
*************/

{{ config(
      materialized='view',
      alias='BAANWAREHOUSINGEDILOGISTICS_USAREGN_TELSHIPPINGADVICEDATA',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        CREATEDDATE,
        DELIVEREDQUANTITY,
        DESCRIPTION,
        ERRORMESSAGE,
        ETADATE,
        EXTRACTTIME,
        FOBNARITADATE,
        HOUSEWAYBILLNO,
        INVOICEDATE,
        INVOICELINE,
        INVOICENUMBER,
        ITEM,
        MESSAGEID,
        PROCESSEDDATE,
        PROCESSEDFLAGDESCRIPTION,
        PROCESSEDFLAGID,
        PURCHASEORDER,
        PURCHASEORDERLINE,
        SALESORDERLINE,
        SALESORDERNO,
        SHIPDATE,
        SHIPTO
    from {{ ref('ODS__BAAN__BAANWAREHOUSINGEDILOGISTICS_USAREGN_TELSHIPPINGADVICEDATA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data