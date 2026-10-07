{{ config(
        materialized='view',
         alias='DAILY_ACTUALS',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        * EXCLUDE (_ROW_HASH, AUDIT_LOG_ID, _FILEDATE)
    FROM {{ ref('COMMON__SAPH__DAILY_ACTUALS') }}
)

SELECT * FROM SOURCE_DATA