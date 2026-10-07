/************
Model file generated from dbtGeneratePubViews: 03.09.2022.17.40.38"
*************/

{{ config(
      materialized='view',
      alias='TBL_AD_MEMBERSHIP',
      transient=false
) }}

with source_data as (
    SELECT
        CHILD_AD_OBJECT_ID,
        PARENT_AD_OBJECT_ID,
        LAST_CHANGED,
        _FILEDATE
    from {{ ref('ODS__LANSWEEPER__TBL_AD_MEMBERSHIP') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data