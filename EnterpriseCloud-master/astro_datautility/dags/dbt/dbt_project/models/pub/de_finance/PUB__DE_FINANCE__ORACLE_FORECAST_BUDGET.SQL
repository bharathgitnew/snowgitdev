{{ config(
        materialized='view',
         alias='ORACLE_FORECAST_BUDGET',
         transient=false
) }}


with SOURCE_DATA AS (
    SELECT 
        *
    FROM {{ ref('COMMON__SAPH__FORECASTBUDGET') }}
)

SELECT * FROM SOURCE_DATA