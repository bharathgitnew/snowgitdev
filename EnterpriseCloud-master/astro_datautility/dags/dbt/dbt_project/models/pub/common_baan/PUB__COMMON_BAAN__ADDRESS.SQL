/************
Model file generated from dbtGeneratePubViews: 04.08.2022.10.56.58"
*************/

{{ config(
      materialized='view',
      alias='ADDRESS',
      transient=false
) }}

with source_data as (
    SELECT
        ADDRESSID,
        NAME,
        NAME2,
        ADDRESS,
        ADDRESS2,
        HOUSENUMBER,
        POBOXNUMBER,
        CITY,
        CITY2,
        ZIPCODEPOSTALCODE,
        TELEPHONE,
        TELEX,
        FAX,
        COUNTRY,
        STATEPROVINCE,
        SEARCHKEY,
        TAXNUMBER,
        VERIFICATIONDATE,
        ADDRESSFORMAT,
        GEOCODE,
        TIMEZONE,
        INTERNET,
        EMAIL,
        TEXT
    from {{ ref('COMMON__BAAN__ADDRESS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data