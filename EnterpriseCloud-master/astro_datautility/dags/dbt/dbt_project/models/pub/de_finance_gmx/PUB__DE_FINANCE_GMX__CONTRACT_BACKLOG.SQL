{{ config(
        materialized='view',
         alias='CONTRACT_BACKLOG',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT
        *
        exclude (_AUDIT_LOG_ID, _ROW_HASH)
    FROM {{ ref('COMMON__REPORTS_GMX__CONTRACT_BACKLOG') }}
),

TRANSFORM_DATA AS (
	SELECT * from SOURCE_DATA
)

SELECT * FROM TRANSFORM_DATA