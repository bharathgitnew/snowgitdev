/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.13.55"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONCOMMONDATA_ADDRESSES',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ADDRESS,
        ADDRESS2,
        ADDRESSCODE,
        ADDRESSFORMAT,
        CALENDARCODE,
        CITY,
        CITY2,
        COUNTRY,
        DATELASTMODIFICATION,
        E_MAIL,
        FAX,
        FRONTOFFICENUMBER,
        GEOCODE,
        HOUSENUMBER,
        INTERNET,
        NAME,
        NAME2,
        POBOXNUMBER,
        ROUTE,
        SEARCHKEY,
        STATEPROVINCE,
        TAXNUMBER,
        TELEPHONE,
        TELEX,
        TEXT,
        TIMEZONE,
        VERIFICATIONDATE,
        ZIPCODEPOSTALCODE
    from {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_ADDRESSES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data