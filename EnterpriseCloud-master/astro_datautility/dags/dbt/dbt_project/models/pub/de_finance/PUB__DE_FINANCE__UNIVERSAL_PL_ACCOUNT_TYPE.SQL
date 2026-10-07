{{ config(
        materialized='view',
         alias='UNIVERSAL_PL_ACCOUNT_TYPE',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        *
    FROM {{ ref('COMMON__SAPH__UNIVERSAL_PL_ACCOUNT_TYPE') }}
)

SELECT * FROM SOURCE_DATA