{{ config(
        materialized='view',
         alias='WIP_SERVICE_DETAILS',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT
        * EXCLUDE (_ROW_HASH,_AUDIT_LOG_ID)
    FROM {{ ref('COMMON__REPORTS__WIP_SERVICE_DETAILS_FIN01') }}
)

SELECT * FROM SOURCE_DATA