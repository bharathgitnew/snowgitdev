{{ config(
      materialized='view',
      alias='SAP_SURB',
      transient=false
) }}

with source_data as (
    SELECT
        * exclude(AUDIT_LOG_ID,_ROW_HASH)
    from {{ ref('COMMON__WISDOM__SAP_SURB') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data