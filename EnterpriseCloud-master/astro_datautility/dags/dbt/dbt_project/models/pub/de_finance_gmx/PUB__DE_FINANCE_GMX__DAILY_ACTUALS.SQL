{{ config(
        materialized='view',
         alias='DAILY_ACTUALS',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        *
    FROM {{ ref('COMMON__SAPH_GMX__DAILY_ACTUALS') }}
)

SELECT * FROM SOURCE_DATA