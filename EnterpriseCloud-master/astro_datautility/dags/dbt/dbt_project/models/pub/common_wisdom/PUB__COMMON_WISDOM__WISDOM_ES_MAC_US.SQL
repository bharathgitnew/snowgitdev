{{ config(
      materialized='view',
      alias='WISDOM_ES_MAC_US',
      transient=false
) }}

with source_data as (
    SELECT
        * exclude(AUDIT_LOG_ID,_ROW_HASH)
    from {{ ref('COMMON__WISDOM__WISDOM_ES_MAC_US') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data