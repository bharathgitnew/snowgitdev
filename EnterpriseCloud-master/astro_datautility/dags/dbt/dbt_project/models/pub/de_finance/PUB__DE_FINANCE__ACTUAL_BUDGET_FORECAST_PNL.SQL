{{ config(
        materialized='view',
         alias='ACTUAL_BUDGET_FORECAST_PNL',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        * exclude (_AUDIT_LOG_ID)
    FROM {{ ref('COMMON__SAPH__ACTUAL_BUDGET_FORECAST_PNL') }}
)

SELECT * FROM SOURCE_DATA