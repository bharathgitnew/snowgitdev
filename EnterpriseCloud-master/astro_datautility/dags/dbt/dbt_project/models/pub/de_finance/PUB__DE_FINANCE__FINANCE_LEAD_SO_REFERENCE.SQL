{{ config(
        materialized='view',
         alias='FINANCE_LEAD_SO_REFERENCE',
         transient=false
) }}


with SOURCE_DATA AS (
    SELECT 
        * exclude (AUDIT_LOG_ID)
    FROM {{ ref('COMMON__REPORTS__FINANCE_LEAD_SO_REFERENCE') }}
)

SELECT * FROM SOURCE_DATA