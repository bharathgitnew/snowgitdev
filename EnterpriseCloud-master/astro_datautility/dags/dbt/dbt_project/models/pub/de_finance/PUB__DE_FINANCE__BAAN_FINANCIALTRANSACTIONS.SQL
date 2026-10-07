{{ config(
        materialized='view',
         alias='BAAN_FINANCIALTRANSACTIONS',
         transient=false
) }}


with SOURCE_DATA AS (
    SELECT 
        *
    FROM {{ ref('ODS__TELUSDWPROD1__FINANCIALTRANSACTIONS') }}
    WHERE CALENDAR_YEAR_MONTH>'2016-03'
)

SELECT * FROM SOURCE_DATA