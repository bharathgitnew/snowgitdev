{{ config(
        materialized='view',
        alias='TAX_FOR_IPR',
        transient=false
) }}

with SOURCE_DATA AS (
    SELECT
        *
        EXCLUDE (AUDIT_LOG_ID)
    FROM {{ ref('COMMON__REPORTS_GMX__TAX_FOR_IPR') }}
)

SELECT * FROM SOURCE_DATA