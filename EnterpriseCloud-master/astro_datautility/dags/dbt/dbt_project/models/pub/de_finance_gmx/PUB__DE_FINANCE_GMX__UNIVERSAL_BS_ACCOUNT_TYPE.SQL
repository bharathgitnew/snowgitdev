{{ config(
        materialized='view',
         alias='UNIVERSAL_BS_ACCOUNT_TYPE',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        *
    FROM {{ ref('COMMON__SAPH_GMX__UNIVERSAL_BS_ACCOUNT_TYPE') }}
)

SELECT * FROM SOURCE_DATA