{{ config(
        materialized='view'    ,
     alias='DEFERRED_REVENUE'    ,
     transient=false
) }}

WITH SOURCE_DATA AS (
    SELECT
        *
        exclude (_AUDIT_LOG_ID, _ROW_HASH )
    FROM {{ ref('COMMON__REPORTS__DEFERRED_REVENUE_FIN01') }}
)

SELECT * FROM SOURCE_DATA