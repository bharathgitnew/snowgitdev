{{ config(
      materialized='view',
      alias='V_WISDOM_FCN_RSN',
      transient=false
) }}

with source_data as (
    SELECT
        * exclude(_AUDIT_LOG_ID,_ROW_HASH)
    from {{ ref('COMMON__WISDOM__WISDOM_FCN_RSN') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data