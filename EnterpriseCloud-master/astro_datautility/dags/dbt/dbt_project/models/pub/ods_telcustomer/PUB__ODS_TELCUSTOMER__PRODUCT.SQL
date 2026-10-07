{{ config(
      materialized='view',
      alias='PRODUCT',
      transient=false
) }}

with source_data as (
    SELECT
        PRODUCT_ID,
        TEL_REGION,
        PART_NBR,
        PRODUCT_DESCR,
        DISABLED,
        DELETED
    from {{ ref('ODS__TELCUSTOMER__PRODUCT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data