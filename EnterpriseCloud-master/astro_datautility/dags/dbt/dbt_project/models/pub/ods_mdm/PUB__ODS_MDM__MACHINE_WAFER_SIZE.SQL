/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.24"
*************/

{{ config(
      materialized='view',
      alias='MACHINE_WAFER_SIZE',
      transient=false
) }}

with source_data as (
    SELECT
        WAFER_SIZE_SOURCE,
        WAFER_SIZE_INCH,
        WAFER_SIZE_MM
    from {{ ref('ODS__MDM__MACHINE_WAFER_SIZE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data