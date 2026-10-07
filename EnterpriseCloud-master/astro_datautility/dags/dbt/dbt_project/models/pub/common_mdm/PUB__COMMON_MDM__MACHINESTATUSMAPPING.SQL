/************
Model file generated from dbtGeneratePubViews: 04.05.2022.12.11.11"
*************/

{{ config(
      materialized='view',
      alias='MACHINESTATUSMAPPING',
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
    from {{ ref('COMMON__MDM__MACHINESTATUSMAPPING') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data