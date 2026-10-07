{{ config(
        materialized='view',
         alias='BAAN_FINANCIALTRANSACTIONS',
         transient=false
) }}


with SOURCE_DATA AS (
    SELECT 
        *
    FROM {{ ref('ODS__TELUSDWPROD1__FINANCIALTRANSACTIONS') }}
    WHERE LEFT(FINANCIALACCOUNTNUMBER,1) IN ('4','5') AND CALENDAR_YEAR_MONTH>'2016-03' AND CALENDAR_YEAR_MONTH<'2023-05'--Validation window, if more legacy data is required then validation for prior months to 2016-03 needed 
)

SELECT * FROM SOURCE_DATA