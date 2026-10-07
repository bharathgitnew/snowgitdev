/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.25"
*************/

{{ config(
      materialized='view',
      alias='BAANWAREHOUSINGEDILOGISTICS_USAREGN_UPSEDI214MESSAGE',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ACCOUNTNO,
        CARRIERTRACKINGNO,
        CREATIONTIME,
        ETACHANGENOTE,
        ETADATE,
        ITEM,
        MESSAGEID,
        ORDER_NUMBER,
        ORDER_ORIGINDESCRIPTION,
        ORDER_ORIGINID,
        POSITIONNUMBER,
        QUANTITYSHIPPED,
        SEQUENCENUMBER,
        SHIPMENTSTATUSDESCRIPTION,
        SHIPMENTSTATUSID,
        STATUSCODE,
        STATUSTIME,
        UPSJOBNUMBER,
        UPSWAREHOUSE,
        WAREHOUSE
    from {{ ref('ODS__BAAN__BAANWAREHOUSINGEDILOGISTICS_USAREGN_UPSEDI214MESSAGE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data