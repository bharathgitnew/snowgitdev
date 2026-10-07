{{ config(
        materialized='view',
         alias='SALES_ORDER',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        *
    FROM {{ ref('COMMON__SAPH_GMX__SALES_ORDER') }}
)

SELECT * FROM SOURCE_DATA