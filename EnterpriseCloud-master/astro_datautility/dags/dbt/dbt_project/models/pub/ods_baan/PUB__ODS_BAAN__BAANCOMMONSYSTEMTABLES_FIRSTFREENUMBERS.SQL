/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.01"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONSYSTEMTABLES_FIRSTFREENUMBERS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        FIRSTFREENUMBER,
        FIRSTFREENUMBERCACHESIZE,
        NUMBERGROUP,
        SERIES,
        SERIESBLOCKEDFORINPUTDESCRIPTION,
        SERIESBLOCKEDFORINPUTID,
        SERIESDESCRIPTION
    from {{ ref('ODS__BAAN__BAANCOMMONSYSTEMTABLES_FIRSTFREENUMBERS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data