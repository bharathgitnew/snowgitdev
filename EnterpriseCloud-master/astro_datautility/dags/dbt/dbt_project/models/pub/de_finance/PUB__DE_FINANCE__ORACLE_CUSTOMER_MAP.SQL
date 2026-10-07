{{ config(
        materialized='view',
         alias='ORACLE_CUSTOMER_MAP',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        *
    FROM {{ ref('COMMON__SAPH__ORACLE_CUSTOMER_MAP') }}
)

SELECT * FROM SOURCE_DATA