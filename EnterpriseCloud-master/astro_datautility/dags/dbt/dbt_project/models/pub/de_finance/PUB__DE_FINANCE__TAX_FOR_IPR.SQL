{{ config(
        materialized='view',
        schema='DE_FINANCE',
        alias='TAX_FOR_IPR',
        transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        *
        EXCLUDE (AUDIT_LOG_ID)
    FROM {{ ref('COMMON__REPORTS__TAX_FOR_IPR') }}
)

SELECT * FROM SOURCE_DATA