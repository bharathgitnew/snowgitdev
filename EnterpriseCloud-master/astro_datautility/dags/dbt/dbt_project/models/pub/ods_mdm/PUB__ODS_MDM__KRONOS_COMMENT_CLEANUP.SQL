/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.23"
*************/

{{ config(
      materialized='view',
      alias='KRONOS_COMMENT_CLEANUP',
      transient=false
) }}

with source_data as (
    SELECT
        COMMENTTYPE,
        CURRENTVALUE,
        CLEANEDVALUE
    from {{ source('ODS__MDM', 'KRONOS_COMMENT_CLEANUP') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data