{{ config(
        materialized='view',
         alias='DAILY_ACTUALS_HISTORICAL_PNL',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        * exclude (AUDIT_LOG_ID)
    FROM {{ ref('COMMON__SAPH__DAILY_ACTUALS_HISTORICAL_PNL') }}
)

SELECT * FROM SOURCE_DATA