{{ config(
        materialized='view',
         alias='PARTS_ACCRUAL_VALIDATION_MONTHLY',
         transient=false,
        tags=["first_of_month_gmx"]
) }}

with SOURCE_DATA AS (
    SELECT
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    FROM {{ ref('COMMON__REPORTS_GMX__PARTS_ACCRUAL_VALIDATION_MONTHLY') }}
)

SELECT * FROM SOURCE_DATA