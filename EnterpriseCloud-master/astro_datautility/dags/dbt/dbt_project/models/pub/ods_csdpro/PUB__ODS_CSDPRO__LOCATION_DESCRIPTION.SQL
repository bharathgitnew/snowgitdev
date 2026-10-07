/************
Model file generated from dbtGeneratePubViews: 11.03.2022.11.24.29"
*************/

{{ config(
      materialized='view',
      alias='LOCATION_DESCRIPTION',
      transient=false
) }}

with source_data as (
    SELECT
        LOCATION_DESCRIPTION_ID,
        DESCRIPTION,
        SORT_ORDER,
        INACTIVE_DATE--,
        --_FILEDATE,
        --_FILENAME
    from {{ ref('ODS__CSDPRO__LOCATION_DESCRIPTION') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data