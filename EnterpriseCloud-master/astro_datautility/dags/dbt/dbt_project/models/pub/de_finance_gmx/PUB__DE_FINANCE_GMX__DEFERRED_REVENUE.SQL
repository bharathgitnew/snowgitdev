{{ config(
        materialized='view'    ,
     alias='DEFERRED_REVENUE'    ,
     transient=false
) }}

WITH SOURCE_DATA AS (
    SELECT
        *
        exclude (_AUDIT_LOG_ID, _ROW_HASH )
    FROM {{ ref('COMMON__REPORTS_GMX__DEFERRED_REVENUE') }}
)

SELECT * FROM SOURCE_DATA