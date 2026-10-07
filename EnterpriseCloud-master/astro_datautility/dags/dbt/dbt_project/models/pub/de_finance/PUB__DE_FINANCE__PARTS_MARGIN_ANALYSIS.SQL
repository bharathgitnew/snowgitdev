{{ config(
        materialized='view',
         alias='PARTS_MARGIN_ANALYSIS',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        * EXCLUDE(_AUDIT_LOG_ID,_ROW_HASH)
    FROM {{ ref('COMMON__REPORTS__PARTS_MARGIN_ANALYSIS') }}
)

SELECT * FROM SOURCE_DATA