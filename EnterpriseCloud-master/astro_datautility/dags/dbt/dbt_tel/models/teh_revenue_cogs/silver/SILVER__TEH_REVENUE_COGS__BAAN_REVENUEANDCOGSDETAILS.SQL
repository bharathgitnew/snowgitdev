{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
         alias='BAAN_REVENUEANDCOGSDETAILS',
         transient=false
) }}


with SOURCE_DATA AS (
    SELECT 
        *
    FROM {{ ref('BRONZE__TEH_REVENUE_COGS__TELUSDWPROD1_REVENUEANDCOGSDETAILS') }}
    WHERE CALENDAR_YEAR_MONTH>'2016-03' AND CALENDAR_YEAR_MONTH<'2023-05'--Validation window, if more legacy data is required then validation for prior months to 2016-03 needed 
)

SELECT * FROM SOURCE_DATA