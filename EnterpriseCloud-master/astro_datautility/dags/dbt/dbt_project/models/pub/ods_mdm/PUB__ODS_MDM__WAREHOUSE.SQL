/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.34"
*************/

{{ config(
      materialized='view',
      alias='WAREHOUSE',
      transient=false
) }}

with source_data as (
    SELECT
        WAREHOUSEID,
        WAREHOUSERELATIONSHIP,
        WAREHOUSECLASSIFICATION,
        ACTIVEFLAG,
        INTELFLAG
    from {{ ref('ODS__MDM__WAREHOUSE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data