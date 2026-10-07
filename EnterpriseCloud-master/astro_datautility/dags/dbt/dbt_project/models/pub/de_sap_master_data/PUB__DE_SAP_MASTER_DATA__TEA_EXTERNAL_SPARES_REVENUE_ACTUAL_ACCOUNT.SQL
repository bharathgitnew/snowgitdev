{{ config(
        materialized='view',
         alias='TEA_EXTERNAL_SPARES_REVENUE_ACTUAL_ACCOUNT',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        * exclude (AUDIT_LOG_ID)
    FROM {{ ref('COMMON__REPORTS__TEA_EXTERNAL_SPARES_REVENUE_ACTUAL_ACCOUNT') }}
)

SELECT * FROM SOURCE_DATA