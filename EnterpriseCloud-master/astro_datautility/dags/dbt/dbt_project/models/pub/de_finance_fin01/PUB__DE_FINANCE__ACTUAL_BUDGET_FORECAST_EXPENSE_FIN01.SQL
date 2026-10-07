{{ config(
        materialized='view',
         alias='ACTUAL_BUDGET_FORECAST_EXPENSE',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        *
        EXCLUDE (_AUDIT_LOG_ID, _ROW_HASH)
    FROM {{ ref('COMMON__SAPH__ACTUAL_BUDGET_FORECAST_EXPENSE_FIN01') }}
)

SELECT * FROM SOURCE_DATA