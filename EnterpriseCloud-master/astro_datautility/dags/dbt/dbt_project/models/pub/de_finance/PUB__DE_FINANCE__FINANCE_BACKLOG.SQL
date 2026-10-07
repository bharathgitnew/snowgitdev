{{ config(
        materialized='view',
         alias='FINANCE_BACKLOG',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        *
        EXCLUDE (_AUDIT_LOG_ID, _ROW_HASH)
    FROM {{ ref('COMMON__REPORTS__FINANCE_BACKLOG') }}
)

SELECT * FROM SOURCE_DATA