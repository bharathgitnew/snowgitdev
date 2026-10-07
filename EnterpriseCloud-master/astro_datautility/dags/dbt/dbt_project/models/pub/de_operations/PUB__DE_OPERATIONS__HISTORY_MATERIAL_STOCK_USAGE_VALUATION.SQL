{{ config(
        materialized='view',
         alias='HISTORY_MATERIAL_STOCK_USAGE_VALUATION',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        * EXCLUDE (_AUDIT_LOG_ID, _ROW_HASH)
    FROM {{ ref('COMMON__REPORTS__HISTORY_MATERIAL_STOCK_USAGE_VALUATION') }}
)

SELECT * FROM SOURCE_DATA