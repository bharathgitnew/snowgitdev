{{ config(
        materialized='view',
         alias='DAILY_ACTUALS_SALES_LINE',
         transient=false
) }}


with SOURCE_DATA AS (
    SELECT 
        *
    FROM {{ ref('COMMON__SAPH_GMX__DAILY_ACTUALS_SALES_LINE') }}
)

SELECT * FROM SOURCE_DATA