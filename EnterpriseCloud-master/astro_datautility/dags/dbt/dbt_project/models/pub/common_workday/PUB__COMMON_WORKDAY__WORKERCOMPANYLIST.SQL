/************
Model file generated from dbtGeneratePubViews: 04.08.2022.10.58.44"
*************/

{{ config(
      materialized='view',
      alias='WORKERCOMPANYLIST',
      transient=false
) }}

with source_data as (
    SELECT
        * exclude(AUDIT_LOG_ID,_ROW_HASH)
    from {{ ref('COMMON__WORKDAY__WORKERCOMPANYLIST') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data