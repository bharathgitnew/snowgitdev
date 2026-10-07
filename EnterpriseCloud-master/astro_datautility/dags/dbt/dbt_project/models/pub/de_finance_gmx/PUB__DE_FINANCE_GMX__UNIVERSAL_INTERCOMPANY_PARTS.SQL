{{ config(
        materialized='view',
         alias='UNIVERSAL_INTERCOMPANY_PARTS',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        * EXCLUDE (_AUDIT_LOG_ID,_ROW_HASH)
    FROM {{ ref('COMMON__SAPH_GMX__UNIVERSAL_INTERCOMPANY_PARTS') }}
)

SELECT * FROM SOURCE_DATA