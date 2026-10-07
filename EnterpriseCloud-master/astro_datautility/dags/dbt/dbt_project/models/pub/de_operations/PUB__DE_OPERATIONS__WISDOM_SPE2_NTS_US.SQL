{{ config(
      materialized='view',
      alias='WISDOM_SPE2_NTS_US',
      transient=false
) }}

with source_data as (
    SELECT
        * exclude(AUDIT_LOG_ID,_ROW_HASH)
    from {{ ref('COMMON__WISDOM__ES_TPS_SPS_NTS_US') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data