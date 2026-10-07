/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.13.58"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONCOMMONDATA_SHIPFROMBUSINESSPARTNERS',
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
        BUYFROMBUSINESSPARTNER,
        CALENDARCODE,
        CARRIER,
        CONTACTCODE,
        ENDDATE,
        INSPECTIONDESCRIPTION,
        INSPECTIONID,
        LANGUAGE,
        SEARCHKEY,
        SHIPFROMBUSINESSPARTNER,
        STARTDATE,
        TEXT,
        VENDORRATINGDESCRIPTION,
        VENDORRATINGID,
        WAREHOUSE
    from {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_SHIPFROMBUSINESSPARTNERS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data