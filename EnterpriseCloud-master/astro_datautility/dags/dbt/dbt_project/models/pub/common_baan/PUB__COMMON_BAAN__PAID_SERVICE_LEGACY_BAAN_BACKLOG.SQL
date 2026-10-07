{{ config(
      materialized='view',
      alias='PAID_SERVICE_LEGACY_BAAN_BACKLOG',
      transient=false
) }}

with source_data as (
    SELECT
        * exclude(_ROW_HASH,AUDIT_LOG_ID)
    from {{ ref('COMMON__BAAN__PAID_SERVICE_LEGACY_BAAN_BACKLOG') }}
)

    select * from source_data