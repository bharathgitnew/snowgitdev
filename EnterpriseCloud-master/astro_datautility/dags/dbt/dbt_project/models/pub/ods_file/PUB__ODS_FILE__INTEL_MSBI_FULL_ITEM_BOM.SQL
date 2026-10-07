{{ config(
      materialized='view',
      alias='INTEL_MSBI_FULL_ITEM_BOM',
      transient=false
) }}

with source_data as (
    SELECT
        * exclude(_ROW_HASH,AUDIT_LOG_ID)
    from {{ ref('ODS__FILE__INTEL_MSBI_FULL_ITEM_BOM') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data