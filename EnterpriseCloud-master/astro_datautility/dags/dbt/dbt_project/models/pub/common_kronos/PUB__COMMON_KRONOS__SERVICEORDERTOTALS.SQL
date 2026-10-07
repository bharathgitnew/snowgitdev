/************
Model file generated from dbtGeneratePubViews: 02.03.2023.17.18.25"
*************/

{{ config(
      materialized='view',
      alias='SERVICEORDERTOTALS',
      transient=false
) }}

with source_data as (
    SELECT
        FIRSTTIMESHEETENTRY,
        LASTTIMESHEETENTRY,
        SERVICEORDER,
        TOTALHOURSWORKED,
        TOTALHOURSWORKEDLAST30DAYS
    from {{ ref('COMMON__KRONOS__SERVICEORDERTOTALS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data