/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.31"
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
    from {{ ref('ODS__MDM__TASTASK') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data