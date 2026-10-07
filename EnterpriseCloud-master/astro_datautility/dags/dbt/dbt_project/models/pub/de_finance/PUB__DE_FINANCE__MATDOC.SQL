{{ config(
        materialized='view',
        alias='MATDOC',
        transient=false
) }}

WITH 
SOURCE_DATA AS (
    SELECT * EXCLUDE (AUDIT_LOG_ID, _ROW_HASH)
    FROM {{ ref('COMMON__SAPH__MATDOC') }}
)
SELECT * FROM SOURCE_DATA