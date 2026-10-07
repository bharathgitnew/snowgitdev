{{ config(
        materialized='view',
         alias='BAAN_REVENUEANDCOGSDETAILS',
         transient=false
) }}


with SOURCE_DATA AS (
    SELECT 
        *
    FROM {{ ref('ODS__TELUSDWPROD1__REVENUEANDCOGSDETAILS') }}
)

SELECT * FROM SOURCE_DATA