/************
Model file generated from dbtGeneratePubViews: 04.05.2022.12.11.13"
*************/

{{ config(
      materialized='view',
      alias='WRENCHTIME',
      transient=false
) }}

with source_data as (
    SELECT
        PAYCODE_NAME,
        ORG_MAP_TYPE,
        TASK,
        TASK_WRENCH_TYPE
    from {{ ref('COMMON__MDM__WRENCHTIME') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data