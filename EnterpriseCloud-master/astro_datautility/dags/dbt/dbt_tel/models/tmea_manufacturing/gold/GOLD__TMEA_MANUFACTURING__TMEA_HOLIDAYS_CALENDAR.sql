{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='TMEA_HOLIDAYS_CALENDAR',
    	transient=false
) }}


WITH 
CTE_CALENDAR_DATE AS (
    SELECT 
        CALENDAR_DATE, 
        IS_WEEK_DAY,
        IS_WORKDAY,
        IS_WEEKEND,
        MONTH_OF_YEAR_NUMBER,
        WORK_WEEK_OF_YEAR_NUMBER,
        DAY_OF_YEAR_NUMBER,
        DAY_OF_WEEK_NUMBER,
        YEAR_TEXT,
        QUARTER_SHORT_TEXT,
        MONTH_TEXT,
        MONTH_ABBREVIATION_TEXT,
        DAY_TEXT,
        FISCAL_YEAR_TEXT,
        FISCAL_YEAR_SHORT_TEXT,
        FISCAL_YEAR_QUARTER_SHORT_TEXT,
        WORK_WEEK_BEGINNING_DATE,
        FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT        
    FROM
        {{ source('STATIC_OBJECTS', 'CALENDAR_DATE') }}
    WHERE
        CALENDAR_DATE > '2021-01-01' AND
        CALENDAR_DATE <= DATEADD(year, 5, CURRENT_DATE())  -- Up to 5 years from today
),
CTE_TMEA_WORK_CALENDAR AS (
    SELECT 
        DATE      
    FROM
     {{ ref('SILVER__TMEA_MANUFACTURING__TMEA_WORK_CALENDAR') }}
    WHERE
        DATE > '2021-01-01' AND
        DATE <= DATEADD(year, 5, CURRENT_DATE())  -- Up to 5 years from today
),
transform_data as (
    select distinct
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
        cd.CALENDAR_DATE,
        cd.IS_WEEK_DAY,
        cd.IS_WORKDAY,
        cd.IS_WEEKEND,
        cd.MONTH_OF_YEAR_NUMBER,
        cd.WORK_WEEK_OF_YEAR_NUMBER,
        cd.DAY_OF_YEAR_NUMBER,
        cd.DAY_OF_WEEK_NUMBER,
        cd.YEAR_TEXT,
        cd.QUARTER_SHORT_TEXT,
        cd.MONTH_TEXT,
        cd.MONTH_ABBREVIATION_TEXT,
        cd.DAY_TEXT,
        cd.FISCAL_YEAR_TEXT,
        cd.FISCAL_YEAR_SHORT_TEXT,
        cd.FISCAL_YEAR_QUARTER_SHORT_TEXT,
        cd.WORK_WEEK_BEGINNING_DATE,
        cd.FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT,
        twc.DATE AS WORK_CALENDAR_DATE,
        CASE 
            WHEN twc.DATE IS NULL AND cd.IS_WEEKEND = 'No' THEN cd.CALENDAR_DATE
            ELSE NULL
        END AS TMEA_HOLIDAYS
        FROM CTE_CALENDAR_DATE cd
        LEFT JOIN CTE_TMEA_WORK_CALENDAR twc ON cd.CALENDAR_DATE = twc.DATE
        ORDER BY 
            cd.CALENDAR_DATE ASC),
type_data as (
    select
        cast(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
        cast(CALENDAR_DATE as DATE) as CALENDAR_DATE,
        IS_WEEK_DAY,
        IS_WORKDAY,
        IS_WEEKEND,
        MONTH_OF_YEAR_NUMBER,
        WORK_WEEK_OF_YEAR_NUMBER,
        DAY_OF_YEAR_NUMBER,
        DAY_OF_WEEK_NUMBER,
        YEAR_TEXT,
        QUARTER_SHORT_TEXT,
        MONTH_TEXT,
        MONTH_ABBREVIATION_TEXT,
        DAY_TEXT,
        FISCAL_YEAR_TEXT,
        FISCAL_YEAR_SHORT_TEXT,
        FISCAL_YEAR_QUARTER_SHORT_TEXT,
        cast(WORK_WEEK_BEGINNING_DATE as DATE) as WORK_WEEK_BEGINNING_DATE,
        FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT,
        cast(WORK_CALENDAR_DATE as DATE) as WORK_CALENDAR_DATE,
        cast(TMEA_HOLIDAYS as DATE) as TMEA_HOLIDAYS
    from transform_data
)
SELECT 
    *
FROM type_data



