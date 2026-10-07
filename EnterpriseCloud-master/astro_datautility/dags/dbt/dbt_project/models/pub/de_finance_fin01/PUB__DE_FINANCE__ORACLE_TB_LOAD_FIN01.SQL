{{ config(
        materialized='view',
         alias='ORACLE_TB_LOAD',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        * exclude (AUDIT_LOG_ID)
    FROM {{ ref('COMMON__SAPH__ORACLE_TB_LOAD_FIN01') }}
)

SELECT * FROM SOURCE_DATA