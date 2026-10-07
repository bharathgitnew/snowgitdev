{{ config(
        materialized='view',
         alias='DAILY_ACTUALS_EXPENSE',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        * EXCLUDE (AUDIT_LOG_ID, _ROW_HASH)
    FROM {{ ref('COMMON__SAPH__DAILY_ACTUALS_EXPENSE_FIN01') }}
)

SELECT * FROM SOURCE_DATA