{{ config(
        materialized='view',
        alias='DAILY_ACTUALS_HISTORICAL_EXPENSE',
        transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        * exclude (AUDIT_LOG_ID)
    FROM {{ ref('COMMON__SAPH_GMX__DAILY_ACTUALS_HISTORICAL_EXPENSE') }}
)

SELECT * FROM SOURCE_DATA