/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.13.57"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONCOMMONDATA_PAYBYBUSINESSPARTNERS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ADDRESSCODE,
        BANK,
        BUSINESSPARTNERSIGNAL,
        BUSINESSPARTNERSTATUSDESCRIPTION,
        BUSINESSPARTNERSTATUSID,
        BUSINESSPARTNERTYPE,
        CALENDARCODE,
        CONTACTCODE,
        CURRENCY,
        DEPARTMENT,
        ENDDATE,
        EXCHANGERATETYPE,
        EXTRADAYSAFTERDUEDATE,
        LANGUAGE,
        PAYFROMBUSINESSPARTNER,
        REMINDERMETHOD,
        REMITTOADDRESS,
        SEARCHKEY,
        STARTDATE,
        TEXT
    from {{ source('ODS__BAAN', 'BAANCOMMONCOMMONDATA_PAYBYBUSINESSPARTNERS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data