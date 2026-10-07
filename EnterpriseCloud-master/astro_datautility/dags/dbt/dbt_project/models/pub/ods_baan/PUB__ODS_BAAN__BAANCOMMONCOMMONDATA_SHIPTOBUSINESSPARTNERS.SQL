/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.13.58"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONCOMMONDATA_SHIPTOBUSINESSPARTNERS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ADDRESSCODE,
        BUSINESSPARTNERSIGNAL,
        BUSINESSPARTNERSTATUSDESCRIPTION,
        BUSINESSPARTNERSTATUSID,
        BUSINESSPARTNERTYPE,
        CALENDARCODE,
        CONTACTCODE,
        ENDDATE,
        FORWARDINGAGENT,
        LANGUAGE,
        SEARCHKEY,
        SHIPTOBUSINESSPARTNER,
        SOLDTOBUSINESSPARTNER,
        STARTDATE,
        TEXT,
        WAREHOUSE
    from {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_SHIPTOBUSINESSPARTNERS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data