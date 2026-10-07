/************
Model file generated from dbtGeneratePubViews: 02.03.2023.17.18.25"
*************/

{{ config(
      materialized='view',
      alias='CONTRACTTOTALS',
      transient=false
) }}

with source_data as (
    SELECT
        CONTRACTNUMBER,
        COVEREDHOURS,
        COVEREDHOURS_FLEX,
        KRONOSDELTA,
        KRONOSDELTA_FLEX,
        KRONOSHOURS,
        KRONOSHOURS_FLEX,
        KRONOSPERCENTAGE,
        KRONOSPERCENTAGE_FLEX,
        TSRDELTA,
        TSRDELTA_FLEX,
        TSRHOURS,
        TSRPERCENTAGE,
        TSRPERCENTAGE_FLEX,
        TOTALCONTRACTAMOUNT
    from {{ ref('COMMON__KRONOS__CONTRACTTOTALS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data