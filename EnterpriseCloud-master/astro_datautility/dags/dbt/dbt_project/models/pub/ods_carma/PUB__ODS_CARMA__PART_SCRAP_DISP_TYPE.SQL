/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.28.52"
*************/

{{ config(
      materialized='view',
      alias='PART_SCRAP_DISP_TYPE',
      transient=false
) }}

with source_data as (
    SELECT
        PART_SCRAP_DISP_TYPE_ID,
        NAME,
        DESCRIPTION,
        SORT_ORDER,
        INACTIVE_DT,
        ACTIVE
    from {{ ref('ODS__CARMA__PART_SCRAP_DISP_TYPE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data