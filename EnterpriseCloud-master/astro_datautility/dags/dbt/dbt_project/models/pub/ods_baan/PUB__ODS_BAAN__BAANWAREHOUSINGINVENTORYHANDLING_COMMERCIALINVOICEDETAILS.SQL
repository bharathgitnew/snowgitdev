/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.26"
*************/

{{ config(
      materialized='view',
      alias='BAANWAREHOUSINGINVENTORYHANDLING_COMMERCIALINVOICEDETAILS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        AESAPPROVEDBY,
        AESAPPROVEDDATE,
        AESCODE,
        AESPARAMETER,
        AESSTATEMENT,
        ATCIDESCRIPTION,
        ATCIID,
        CIREFERENCE,
        COMMERCIALINVOICE,
        CONTACTINFO,
        COUNTRYOFDESTINATION,
        CREATEDATE,
        CREATIONDATE,
        CUSTOMERCARRIERACCOUNT,
        CUSTOMERORDERNUMBER,
        CUSTOMERORDERPO,
        DEPARTMENT,
        DESTCONTROLSTATEMENTCODE,
        ETA,
        ETD,
        EXPORTDESCRIPTION,
        EXPORTID,
        EXPORTLICENSECATERY,
        FINALIZATIONDATE,
        FLIGHTNO,
        FREIGHTTERMSDESCRIPTION,
        FREIGHTTERMSID,
        HOUSEAIRWAYBILL,
        LICENCE,
        MASTERAIRWAYBILL,
        MESSAGE,
        MODEDESCRIPTION,
        MODEID,
        ORDER_,
        PORTOFDELIVERY,
        PORTOFEXPORT,
        PRDTU,
        REMARKS,
        REVISEDECCN,
        REVISEDQUANTITY,
        SHIPMENTIDENTIFICATION,
        SHIPTOBP,
        SHIPVIACARRIER,
        SOLDTOBP,
        STATUSDESCRIPTION,
        STATUSID,
        TELP,
        TERMSOFDELIVERY,
        TERMSOFPAYMENT,
        TEXT,
        UNIQUEID,
        UPSACCOUNT,
        UPSWAREHOUSE,
        WAREHOUSE
    from {{ ref('ODS__BAAN__BAANWAREHOUSINGINVENTORYHANDLING_COMMERCIALINVOICEDETAILS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data