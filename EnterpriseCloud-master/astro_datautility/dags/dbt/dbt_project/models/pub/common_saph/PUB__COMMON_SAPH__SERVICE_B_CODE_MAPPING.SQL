{{ config(
      materialized='view',
      alias='SERVICE_B_CODE_MAPPING',
      transient=false
) }}

with source_data as (
    SELECT *
    from {{ ref('COMMON__SAPH__SERVICE_B_CODE_MAPPING') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data