{{ config(
        materialized='view',
         alias='VENDOR_INVOICES',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        * EXCLUDE (_ROW_HASH,_AUDIT_LOG_ID)
    FROM {{ ref('COMMON__REPORTS__VENDOR_INVOICES_FIN01') }}
)

SELECT * FROM SOURCE_DATA