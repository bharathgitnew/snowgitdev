{{ config(
        materialized='view',
         alias='INTERCOMPANY_REVENUE_COGS',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        * EXCLUDE (_AUDIT_LOG_ID,_ROW_HASH)
    FROM {{ ref('COMMON__REPORTS__INTERCOMPANY_REVENUE_COGS') }}
)

SELECT * FROM SOURCE_DATA