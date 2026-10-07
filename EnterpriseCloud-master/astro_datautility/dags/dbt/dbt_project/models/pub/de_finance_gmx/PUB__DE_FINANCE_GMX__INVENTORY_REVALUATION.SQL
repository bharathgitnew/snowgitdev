{{ config(
        materialized='view',
        alias='INVENTORY_REVALUATION',
        transient=false
) }}

WITH 
SOURCE_DATA AS (
    SELECT * EXCLUDE (_AUDIT_LOG_ID, _ROW_HASH)
    FROM {{ ref('COMMON__REPORTS_GMX__INVENTORY_REVALUATION') }}
)
SELECT * FROM SOURCE_DATA