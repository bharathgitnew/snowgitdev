{{ config(
        materialized='view',
        schema='DE_FINANCE_FIN01',
        alias='TAX_FOR_IPR',
        transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        *
        EXCLUDE (AUDIT_LOG_ID)
    FROM {{ ref('COMMON__REPORTS__TAX_FOR_IPR_FIN01') }}
)

SELECT * FROM SOURCE_DATA