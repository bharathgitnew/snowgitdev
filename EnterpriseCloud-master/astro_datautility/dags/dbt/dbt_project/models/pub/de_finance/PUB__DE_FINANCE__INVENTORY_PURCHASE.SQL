{{ config(
        materialized='view',
        alias='INVENTORY_PURCHASE',
        transient=false
) }}

WITH 
SOURCE_DATA AS (
    SELECT * EXCLUDE (_AUDIT_LOG_ID, _ROW_HASH)
    FROM {{ ref('COMMON__REPORTS__INVENTORY_PURCHASE') }}
)
SELECT * FROM SOURCE_DATA