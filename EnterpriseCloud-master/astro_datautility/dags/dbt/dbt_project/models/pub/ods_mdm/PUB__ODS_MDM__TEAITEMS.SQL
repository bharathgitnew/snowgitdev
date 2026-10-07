/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.33"
*************/

{{ config(
      materialized='view',
      alias='TEAITEMS',
      transient=false
) }}

with source_data as (
    SELECT
        ITEMID,
        CLASSIFICATION
    from {{ ref('ODS__MDM__TEAITEMS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data