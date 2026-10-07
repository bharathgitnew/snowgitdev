/************
Model file generated from dbtGeneratePubViews: 04.05.2022.12.11.11"
*************/

{{ config(
      materialized='view',
      alias='MACHINEWAFERSIZE',
      transient=false
) }}

with source_data as (
    SELECT
        WAFER_SIZE_SOURCE,
        WAFER_SIZE_INCH,
        WAFER_SIZE_MM
    from {{ ref('COMMON__MDM__MACHINEWAFERSIZE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data