{{ config(
      materialized='view',
      schema='de_operations',
      alias='INTEL_VFBOM',
      transient=false
) }}

with source_data as (
    SELECT
        * exclude(_AUDIT_LOG_ID,_ROW_HASH)
    from {{ ref('COMMON__SAPH__INTEL_VFBOM') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data