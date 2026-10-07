/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.24"
*************/

{{ config(
      materialized='view',
      alias='MACHINE_STATUS_MAPPING',
      transient=false
) }}

with source_data as (
    SELECT
        STATUS_KEY,
        MACHINE_STATUS,
        EXPIRED_FLAG,
        EVAL_FLAG,
        INSTALL_BASE_STATUS,
        STATUS_SORT
    from {{ ref('ODS__MDM__MACHINE_STATUS_MAPPING') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data