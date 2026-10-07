/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.23"
*************/

{{ config(
      materialized='view',
      alias='KRONOS_SHIFT_TABLE',
      transient=false
) }}

with source_data as (
    SELECT
        WORK_RULE_NAME,
        SHIFT_INDICATED,
        SHIFT_TYPE
    from {{ ref('ODS__MDM__KRONOS_SHIFT_TABLE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data