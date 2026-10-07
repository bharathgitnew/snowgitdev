{{ config(
      materialized='view',
      alias='WISDOM_SURB_DELAY',
      transient=false
) }}

with source_data as (
    SELECT
        * exclude(AUDIT_LOG_ID,_ROW_HASH)
    from {{ ref('COMMON__WISDOM__WISDOM_SURB_DELAY') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data