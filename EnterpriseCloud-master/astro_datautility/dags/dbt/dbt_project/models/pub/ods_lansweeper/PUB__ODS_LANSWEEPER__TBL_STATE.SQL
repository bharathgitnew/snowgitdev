/************
Model file generated from dbtGeneratePubViews: 03.09.2022.17.40.39"
*************/

{{ config(
      materialized='view',
      alias='TBL_STATE',
      transient=false
) }}

with source_data as (
    SELECT
        STATE,
        STATE_NAME,
        LAST_CHANGED,
        _FILEDATE
    from {{ ref('ODS__LANSWEEPER__TBL_STATE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data