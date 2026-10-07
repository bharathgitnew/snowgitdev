{{ config(
        materialized = 'view',
        alias = 'PRODUCT',
        transient = 'false'
) }}

with source_data as (
    select 
        PRODUCT_ID,
        PRODUCT_NAME
    FROM {{ ref('COMMON__CRM__PRODUCT') }}
),

transform_data as (
    SELECT * FROM source_data
)

SELECT * FROM transform_data