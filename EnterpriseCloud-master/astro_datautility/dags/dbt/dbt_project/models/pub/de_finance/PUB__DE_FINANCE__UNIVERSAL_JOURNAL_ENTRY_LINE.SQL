{{ config(
        materialized='view',
         alias='UNIVERSAL_JOURNAL_ENTRY_LINE',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        *
    FROM {{ ref('COMMON__SAPH__UNIVERSAL_JOURNAL_ENTRY_LINE') }}
)

SELECT * FROM SOURCE_DATA