{{ config(
      materialized='view',
      schema='de_sap_master_data',
      alias='SAP_SALES_CATEGORY',
      transient=false
) }}

with source_data as (
    SELECT
      BAAN_PRODUCT_TYPE,
      BAAN_PRODUCT_TYPE_NAME,
      SAP_SALES_CATEGORY,
      SAP_SALES_CATEGORY_NAME
    from {{ ref('COMMON__SAPH__SAP_SALES_CATEGORY') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data