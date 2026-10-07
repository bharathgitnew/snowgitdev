{{ config(
        materialized='view',
         alias='DAILY_ACTUALS_SALES_LINE_ENHANCED',
         transient=false
) }}


with SOURCE_DATA AS (
    SELECT 
        *
    FROM {{ ref('COMMON__SAPH_GMX__DAILY_ACTUALS_SALES_LINE_ENHANCED') }}
)

SELECT * FROM SOURCE_DATA