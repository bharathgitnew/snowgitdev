/************
Model file generated from dbtGeneratePubViews: 04.05.2022.12.11.12"
*************/

{{ config(
      materialized='view',
      alias='TASTASK',
      transient=false
) }}

with source_data as (
    SELECT
        TASK_NAME,
        TAS_WRENCH_TYPE,
        TAS_TASK
    from {{ ref('COMMON__MDM__TASTASK') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data