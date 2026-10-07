{{ config(
        materialized='view',
         alias='REVENUE_COGS_FAB_DETAIL',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        * exclude (AUDIT_LOG_ID)
    FROM {{ ref('COMMON__REPORTS__REVENUE_COGS_FAB_DETAIL') }}
)

SELECT * FROM SOURCE_DATA