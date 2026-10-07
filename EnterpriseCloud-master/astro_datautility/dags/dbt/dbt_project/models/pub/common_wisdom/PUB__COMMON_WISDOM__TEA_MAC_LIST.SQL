{{ config(
      materialized='view',
      alias='TEA_MAC_LIST',
      transient=false
) }}

with source_data as (
    SELECT
        * exclude(AUDIT_LOG_ID,_ROW_HASH)
    from {{ ref('COMMON__WISDOM__TEA_MAC_LIST') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data