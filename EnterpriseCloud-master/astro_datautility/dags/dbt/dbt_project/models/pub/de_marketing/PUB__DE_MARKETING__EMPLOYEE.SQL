{{ config(
      materialized='view',
      alias='EMPLOYEE',
      transient=false
) }}

with source_data as (
    SELECT
        * exclude(_AUDIT_LOG_ID,_ROW_HASH)
    from {{ ref('COMMON__TEACOMMON__EMPLOYEE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data