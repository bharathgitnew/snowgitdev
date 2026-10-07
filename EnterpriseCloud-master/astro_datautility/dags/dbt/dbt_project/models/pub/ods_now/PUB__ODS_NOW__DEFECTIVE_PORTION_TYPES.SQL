/************
Model file generated from dbtGeneratePubViews: 12.14.2022.18.35.47"
*************/

{{ config(
      materialized='view',
      alias='DEFECTIVE_PORTION_TYPES',
      transient=false
) }}

with source_data as (
    SELECT
        DEFECTIVE_PORTION_ID,
        DESCRIPTION,
        SORT_ORDER
    from {{ ref('ODS__NOW__DEFECTIVE_PORTION_TYPES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data