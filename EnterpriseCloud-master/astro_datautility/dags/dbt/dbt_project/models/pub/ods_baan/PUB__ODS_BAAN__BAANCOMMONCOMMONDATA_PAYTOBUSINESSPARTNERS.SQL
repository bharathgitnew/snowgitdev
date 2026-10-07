/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.13.57"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONCOMMONDATA_PAYTOBUSINESSPARTNERS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ADDRESSCODE,
        BANK,
        BANKFACTORINGCOMPANY,
        BUSINESSPARTNERSIGNAL,
        BUSINESSPARTNERSTATUSDESCRIPTION,
        BUSINESSPARTNERSTATUSID,
        BUSINESSPARTNERTYPE,
        CALENDARCODE,
        CONTACTCODE,
        CURRENCY,
        CUSTOMERNUMBERATFACTOR,
        DEPARTMENT,
        ENDDATE,
        EXCHANGERATETYPE,
        EXTRADAYSAFTERDUEDATE,
        FACTORINGCOMPANY,
        LANGUAGE,
        PAYTOBUSINESSPARTNER,
        SEARCHKEY,
        STARTDATE,
        TEXT,
        VENDORRATINGDESCRIPTION,
        VENDORRATINGID
    from {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_PAYTOBUSINESSPARTNERS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data