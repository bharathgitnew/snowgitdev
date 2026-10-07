{{ config(
        materialized='view',
         alias='SALES_TAX',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        * EXCLUDE(_AUDIT_LOG_ID,_ROW_HASH)
    FROM {{ ref('COMMON__REPORTS__SALES_TAX') }}
)

SELECT * FROM SOURCE_DATA