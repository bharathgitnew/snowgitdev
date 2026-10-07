{{ config(
        materialized='view',
         alias='ORACLE_ACCOUNT_MAP',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        * exclude(_ROW_HASH,_AUDIT_LOG_ID)
    FROM {{ ref('COMMON__SAPH__ORACLE_ACCOUNT_MAP') }}
)

SELECT * FROM SOURCE_DATA