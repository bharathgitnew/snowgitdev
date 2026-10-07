{{ config(
        materialized='view',
         alias='INV_PURCHASES_FINANCE',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        * EXCLUDE (_AUDIT_LOG_ID,_ROW_HASH)
    FROM {{ ref('COMMON__REPORTS__INV_PURCHASES_FINANCE_FIN01') }}
)

SELECT * FROM SOURCE_DATA