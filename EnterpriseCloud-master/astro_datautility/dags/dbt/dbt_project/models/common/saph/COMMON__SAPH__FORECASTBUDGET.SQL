{{ config(
        materialized='incremental',
        incremental_strategy='insert_overwrite',
        alias='FORECASTBUDGET',
        transient=false
) }}

with Qry_MaxBudgetFiledate as (
    SELECT Scenario, YEAR,PERIOD, max(_FILEDATE) as  MaxFileDate 
    FROM {{ ref('ODS__FILE__FORECASTBUDGET') }}
    Where Scenario ILIKE '%Budget%'
    GROUP BY Scenario,YEAR, PERIOD
)
,Qry_MaxForecastFiledate as (
    SELECT Scenario, YEAR, PERIOD,max(_FILEDATE) as  MaxFileDate 
    FROM {{ ref('ODS__FILE__FORECASTBUDGET') }}
    Where Scenario ILIKE '%Forecast%'
    GROUP BY Scenario,YEAR,PERIOD
)
,source_data as
(
    SELECT 
        OracleEPBCSAccount.BaanAccountForBudget AS ACCOUNT,
        FORECASTBUDGET.ACCOUNT AS FILE_ACCOUNT,
        FORECASTBUDGET.ENTITY AS Entity,
        FORECASTBUDGET.UD1 AS DEPARTMENTCODE,
        FORECASTBUDGET.UD2 AS SEGMENTCODE,
        FORECASTBUDGET.UD3 AS OFFICECODE,
        FORECASTBUDGET.UD4 AS FINANCIALPRODUCTCODE,
        FORECASTBUDGET.UD5 AS CUSTOMERCODE,
        FORECASTBUDGET.UD6 AS UD6,
        FORECASTBUDGET.UD7 AS UD7,
        FORECASTBUDGET.UD8 AS VERSION,
        FORECASTBUDGET.SCENARIO AS SCENARIO,
        FORECASTBUDGET.YEAR AS YEAR,
        FORECASTBUDGET.PERIOD AS PERIOD,
        FORECASTBUDGET.CURRENCY AS CURRENCY,
        FORECASTBUDGET.AMOUNT AS AMOUNT,
        FORECASTBUDGET._FILEDATE,
        DATEADD ( MM , - 9 , TO_DATE ( '20' || RIGHT ( FORECASTBUDGET.YEAR , 2 ) || '-' || RIGHT ( '00' || MONTH ( TO_DATE ( FORECASTBUDGET.PERIOD , 'Mon' ) ) , 2 ) || '-' || '01' ) ) AS SCENARIOCREATEDDATE,
        CASE WHEN FORECASTBUDGET._FILEDATE =  Qry_MaxBudgetFiledate.MAXFILEDATE
            THEN 'Y'
            ELSE 'N'
        END AS DISPLAYBUDGETFLAG,
        CASE WHEN FORECASTBUDGET._FILEDATE =  Qry_MaxForecastFiledate.MAXFILEDATE
            THEN 'Y'
            ELSE 'N'
        END AS DISPLAYFORECASTFLAG,
        Case When Account='A4111010-100' Then 'Revenue'
                When Account='A4111010-200' Then 'Revenue'
                When Account='A4111010-300' Then 'Revenue'
                When Account='A5111010-310' Then 'COGS'
                When Account='A5111010-320' Then 'COGS'
                When Account='A5111010-330' Then 'COGS'
                When Account='A5111010-340' Then 'COGS'
                When Account='A5111010-350' Then 'COGS'
                When Account='A5111010-360' Then 'COGS'
                When Account='A5111010-370' Then 'COGS'
                When Account='A5111010-380' Then 'COGS'
                When Account='A5111010-401' Then 'COGS'
                When Account='A5111010-402' Then 'COGS'
                When Account='A5111010-501' Then 'COGS'
                When Account='A5111010-600' Then 'COGS'
                When Account='A5111010-710' Then 'COGS'
                When Account='A5111010-720' Then 'COGS'
                When Account='A5111010-730' Then 'COGS'
                When Account='A5111010-740' Then 'COGS'
                When Account='A5111020-100' Then 'COGS'
                When Account='A5111020-300' Then 'COGS'
                When Account='A5111030-100' Then 'COGS'
                When Account='A5111030-200' Then 'COGS'
                When Account='A5111030-500' Then 'COGS'
                When Account='A5111040-100' Then 'COGS'
                When Account='A5111040-101' Then 'COGS'
                When Account='A5111040-102' Then 'COGS'
                When Account='A5111040-200' Then 'COGS'
                When Account='A5111040-201' Then 'COGS'
                When Account='A5111040-202' Then 'COGS'
                When Account='A5111040-300' Then 'COGS'
                When Account='A5111040-301' Then 'COGS'
                When Account='A5111050-100' Then 'COGS'
                When Account='A5111050-103' Then 'COGS'
                When Account='A5111060-101' Then 'COGS'
                When Account='A5411000-120' Then 'COGS'
                When Account='A5511010-100' Then 'COGS'
                When Account='A5511010-110' Then 'COGS'
                When Account='A5511010-200' Then 'COGS'
                When Account='A5511020' Then 'COGS'
                When Account='A5532010' Then 'COGS'
                When Account='A5599030' Then 'COGS'
                When Account='A5611010-100' Then 'COGS'
                When Account='A5611030-100' Then 'COGS'
                When Account='A5611030-200' Then 'COGS'
                When Account='A5611040' Then 'COGS'
                When Account='A5611070-100' Then 'COGS'
                When Account='A5611080-300' Then 'COGS'
                When Account='A5611090-100' Then 'COGS'
                When Account='A5611090-200' Then 'COGS'
                When Account='A5611090-300' Then 'COGS'
                When Account='A5611090-400' Then 'COGS'
                When Account='A5611100-100' Then 'COGS'
                When Account='A5611210' Then 'COGS'
                When Account='A5611220-100' Then 'COGS'
                When Account='A5611220-300' Then 'COGS'
                When Account='A5611220-400' Then 'COGS'
                When Account='A5611230-100' Then 'COGS'
                When Account='A5611250-100' Then 'COGS'
                When Account='A5611250-200' Then 'COGS'
                When Account='A5611250-300' Then 'COGS'
                When Account='A5611250-400' Then 'COGS'
                When Account='A5611260' Then 'COGS'
                When Account='A5611270' Then 'COGS'
                When Account='A5611280-100' Then 'COGS'
                When Account='A5611280-200' Then 'COGS'
                When Account='A5611280-400' Then 'COGS'
                When Account='A5611281' Then 'COGS'
                When Account='A5611282' Then 'COGS'
                When Account='A5611290-100' Then 'COGS'
                When Account='A5611330-100' Then 'COGS'
                When Account='A5611330-300' Then 'COGS'
                When Account='A5611980' Then 'COGS'
                When Account='A5611990-210' Then 'COGS'
                When Account='A5611990-230' Then 'COGS'
                When Account='A5611990-240' Then 'COGS'
                When Account='A5611990-250' Then 'COGS'
                When Account='A5611990-510' Then 'COGS'
                When Account='A5611990-520' Then 'COGS'
                When Account='A5611990-530' Then 'COGS'
        Else 'NA' END AS ACCOUNT_TYPE
    FROM {{ ref('ODS__FILE__FORECASTBUDGET') }} AS FORECASTBUDGET
    LEFT OUTER JOIN {{ ref('ODS__MDM__ORACLEEPBCSACCOUNT') }} OracleEPBCSAccount ON OracleEPBCSAccount.OracleAccountId =  FORECASTBUDGET.ACCOUNT
    LEFT JOIN Qry_MaxBudgetFiledate
    ON  Qry_MaxBudgetFiledate.SCENARIO =  FORECASTBUDGET.SCENARIO 
    AND  Qry_MaxBudgetFiledate.YEAR =  FORECASTBUDGET.YEAR 
    AND Qry_MaxBudgetFiledate.PERIOD= FORECASTBUDGET.PERIOD
    LEFT JOIN Qry_MaxForecastFiledate
    ON  Qry_MaxForecastFiledate.SCENARIO =  FORECASTBUDGET.SCENARIO 
    AND  Qry_MaxForecastFiledate.YEAR =  FORECASTBUDGET.YEAR 
    AND Qry_MaxForecastFiledate.PERIOD=FORECASTBUDGET.PERIOD
)

,transform_data as (
    SELECT 
       '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        ACCOUNT,
        FILE_ACCOUNT,
        ENTITY,
        DEPARTMENTCODE,
        SEGMENTCODE,
        OFFICECODE,
        FINANCIALPRODUCTCODE,
        CUSTOMERCODE,
        UD6,
        UD7,
        VERSION,
        SCENARIO,
        YEAR,
        PERIOD,
        CURRENCY,
        AMOUNT,
        _FILEDATE,
        SCENARIOCREATEDDATE,
        DISPLAYBUDGETFLAG,
        DISPLAYFORECASTFLAG,
        ACCOUNT_TYPE
    FROM source_data
)

,type_data as (
    SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(ACCOUNT AS VARCHAR(16777216)) AS ACCOUNT,
        CAST(FILE_ACCOUNT AS VARCHAR(16777216)) AS FILE_ACCOUNT,
        CAST(ENTITY AS VARCHAR(16777216)) AS ENTITY,
        CAST(DEPARTMENTCODE AS VARCHAR(16777216)) AS DEPARTMENTCODE,
        CAST(SEGMENTCODE AS VARCHAR(16777216)) AS SEGMENTCODE,
        CAST(OFFICECODE AS VARCHAR(16777216)) AS OFFICECODE,
        CAST(FINANCIALPRODUCTCODE AS VARCHAR(16777216)) AS FINANCIALPRODUCTCODE,
        CAST(CUSTOMERCODE AS VARCHAR(16777216)) AS CUSTOMERCODE,
        CAST(UD6 AS VARCHAR(16777216)) AS UD6,
        CAST(UD7 AS VARCHAR(16777216)) AS UD7,
        CAST(VERSION AS VARCHAR(16777216)) AS VERSION,
        CAST(SCENARIO AS VARCHAR(16777216)) AS SCENARIO,
        CAST(YEAR AS VARCHAR(16777216)) AS YEAR,
        CAST(PERIOD AS VARCHAR(16777216)) AS PERIOD,
        CAST(CURRENCY AS VARCHAR(16777216)) AS CURRENCY,
        CAST(AMOUNT AS VARCHAR(16777216)) AS AMOUNT,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(SCENARIOCREATEDDATE AS TIMESTAMP_NTZ(9)) AS SCENARIOCREATEDDATE,
        CAST(DISPLAYBUDGETFLAG AS VARCHAR(1)) AS DISPLAYBUDGETFLAG,
        CAST(DISPLAYFORECASTFLAG AS VARCHAR(1)) AS DISPLAYFORECASTFLAG,
        CAST(ACCOUNT_TYPE AS  VARCHAR(16777216)) AS ACCOUNT_TYPE
    FROM transform_data
)

SELECT * from type_data