{{ config(
        materialized='view',
         alias='PRODUCT_TYPE_MAP',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        *
    FROM {{ ref('COMMON__SAPH__PRODUCT_TYPE_MAP') }}
)

SELECT * FROM SOURCE_DATA