{{ config(
      materialized='view',
      schema='de_sap_master_data',
      alias='SAP_CUSTOMER',
      transient=false
) }}

with source_data as (
    SELECT
        *
    from {{ ref('COMMON__SAPH__SAP_CUSTOMER') }}
),

transform_data AS (
    select * from source_data
)

    select * from transform_data