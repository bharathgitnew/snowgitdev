/************
Model file generated from dbtGeneratePubViews: 04.08.2022.10.56.59"
*************/

{{ config(
      materialized='view',
      alias='FIRSTFREENUMBERS',
      transient=false
) }}

with source_data as (
    SELECT
        FIRSTFREENUMBER,
        FIRSTFREENUMBERCACHESIZE,
        NUMBERGROUP,
        SERIES,
        SERIESBLOCKEDFORINPUTDESCRIPTION,
        SERIESBLOCKEDFORINPUTID,
        SERIESDESCRIPTION
    from {{ ref('COMMON__BAAN__FIRSTFREENUMBERS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data