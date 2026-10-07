{{ config(
      materialized='view',
      alias='ORACLE_CUSTOMER_MAP',
      transient=false
) }}

with source_data as (
    SELECT
        *
    from {{ ref('COMMON__SAPH__ORACLE_CUSTOMER_MAP') }}
),

transform_data AS (
    select * from source_data
)

    select * from transform_data