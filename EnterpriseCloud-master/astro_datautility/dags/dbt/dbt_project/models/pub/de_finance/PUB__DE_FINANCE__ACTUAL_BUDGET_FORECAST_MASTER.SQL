{{ config(
        materialized='view',
         alias='ACTUAL_BUDGET_FORECAST_MASTER',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        *
    FROM {{ ref('COMMON__SAPH__ACTUAL_BUDGET_FORECAST_MASTER') }}
)

SELECT * FROM SOURCE_DATA