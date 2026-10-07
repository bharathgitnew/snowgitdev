/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.28.51"
*************/

{{ config(
      materialized='view',
      alias='DMG_LIABILITY_DISP_TYPE',
      transient=false
) }}

with source_data as (
    SELECT
        DMG_LIABILITY_DISP_TYPE_ID,
        NAME,
        DESCRIPTION,
        SORT_ORDER,
        INACTIVE_DT,
        ACTIVE
    from {{ ref('ODS__CARMA__DMG_LIABILITY_DISP_TYPE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data