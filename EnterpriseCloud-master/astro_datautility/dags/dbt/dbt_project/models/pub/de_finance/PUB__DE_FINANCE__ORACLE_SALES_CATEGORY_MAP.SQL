{{ config(
        materialized='view',
         alias='ORACLE_SALES_CATEGORY_MAP',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        *
    FROM {{ ref('COMMON__SAPH__ORACLE_SALES_CATEGORY_MAP') }}
)

SELECT * FROM SOURCE_DATA