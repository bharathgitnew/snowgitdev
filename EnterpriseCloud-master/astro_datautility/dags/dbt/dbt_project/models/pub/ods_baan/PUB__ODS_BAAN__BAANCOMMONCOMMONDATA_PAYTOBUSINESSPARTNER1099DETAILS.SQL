/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.13.57"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONCOMMONDATA_PAYTOBUSINESSPARTNER1099DETAILS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        _1099NAME,
        _1NDTINDESCRIPTION,
        _1NDTINID,
        ACCOUNTNUMBER1099,
        ADDRESSCODE,
        DIRECTSALESINDICATORDESCRIPTION,
        DIRECTSALESINDICATORID,
        FOREIGNNON_USENTITYDESCRIPTION,
        FOREIGNNON_USENTITYID,
        INCOMETAXREPORTINGSITE,
        INCOMETAXTYPE,
        PAYEENAMECONTROL,
        PAYTOBUSINESSPARTNER,
        REASONFORPAYMENTS,
        STATEPAYERSSTATENUMBERBOX12,
        TYPEOFTAXIDDESCRIPTION,
        TYPEOFTAXIDID
    from {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_PAYTOBUSINESSPARTNER1099DETAILS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data