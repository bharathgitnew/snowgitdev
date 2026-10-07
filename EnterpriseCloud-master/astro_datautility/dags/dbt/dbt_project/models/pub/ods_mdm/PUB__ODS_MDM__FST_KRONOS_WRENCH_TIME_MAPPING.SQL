/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.22"
*************/

{{ config(
      materialized='view',
      alias='FST_KRONOS_WRENCH_TIME_MAPPING',
      transient=false
) }}

with source_data as (
    SELECT
        PAYCODE_NAME,
        ORG_MAP_TYPE,
        TASK,
        TASK_WRENCH_TYPE
    from {{ ref('ODS__MDM__FST_KRONOS_WRENCH_TIME_MAPPING') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data