{{ config(
        materialized='view',
         alias='PURCHASE_ORDER_LINE_REPORT',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        * EXCLUDE(AUDIT_LOG_ID,_ROW_HASH)
    FROM {{ ref('COMMON__REPORTS__PURCHASE_ORDER_LINE_REPORT') }}
)

SELECT * FROM SOURCE_DATA