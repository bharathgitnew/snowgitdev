{{ config(
        materialized='view',
         alias='ORACLE_TB_LOAD_ENHANCED',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        * exclude (_ROW_HASH,_AUDIT_LOG_ID)
    FROM {{ ref('COMMON__SAPH_GMX__ORACLE_TB_LOAD_ENHANCED') }}
)

SELECT * FROM SOURCE_DATA