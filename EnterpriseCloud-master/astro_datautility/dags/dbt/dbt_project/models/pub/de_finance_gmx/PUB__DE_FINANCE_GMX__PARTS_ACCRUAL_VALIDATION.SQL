{{ config(
        materialized='view',
        alias='PARTS_ACCRUAL_VALIDATION',
        transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    FROM {{ ref('COMMON__REPORTS_GMX__PARTS_ACCRUAL_VALIDATION') }}
)

SELECT * FROM SOURCE_DATA