{{ config(
      materialized='view',
      alias='WISDOM_MACHINE_FCNS',
      transient=false
) }}

with source_data as (
    SELECT
            * exclude(AUDIT_LOG_ID,_ROW_HASH)
    from {{ ref('COMMON__WISDOM__WISDOM_MACHINE_FCNS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data