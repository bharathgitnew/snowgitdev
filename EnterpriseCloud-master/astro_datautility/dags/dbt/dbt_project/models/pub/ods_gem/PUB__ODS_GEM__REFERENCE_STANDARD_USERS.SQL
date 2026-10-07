{{ config(
      materialized='view',
      alias='REFERENCE_STANDARD_USERS',
      transient=false
) }}


with source_data as (
    SELECT
        * exclude(_AUDIT_LOG_ID,_ROW_HASH)
    from {{ ref('ODS__GEM__REFERENCE_STANDARD_USERS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data