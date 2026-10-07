{{ config(
        materialized='view',
         alias='DAILY_ACTUALS_SALES_LINE_SNAPSHOT',
         transient=false
) }}


with SOURCE_DATA AS (
    SELECT 
        *
    FROM {{ ref('COMMON__SAPH__DAILY_ACTUALS_SALES_LINE_SNAPSHOT_FIN01') }}
)

SELECT * FROM SOURCE_DATA