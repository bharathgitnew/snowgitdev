{{ config(
        materialized='view',
         alias='ACTUAL_BUDGET_FORECAST_MASTER',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        *
    FROM {{ ref('COMMON__SAPH__ACTUAL_BUDGET_FORECAST_MASTER_FIN01') }}
)

SELECT * FROM SOURCE_DATA