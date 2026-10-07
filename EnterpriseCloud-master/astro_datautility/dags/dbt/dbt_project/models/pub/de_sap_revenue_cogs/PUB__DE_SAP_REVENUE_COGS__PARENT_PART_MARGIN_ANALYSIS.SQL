{{ config(
        materialized='view',
         alias='PARENT_PART_MARGIN_ANALYSIS',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        * exclude (_AUDIT_LOG_ID,_ROW_HASH)
    FROM {{ ref('COMMON__REPORTS__PARENT_PART_MARGIN_ANALYSIS') }}
)

SELECT * FROM SOURCE_DATA