{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='FILE_FORECASTBUDGET_EPBCS',
    unique_key = ['_FileDate',
    'ACCOUNT_NUMBER_EPBCS',
    'SUBS',
    'DEPARTMENT',
    'SEGMENT',
    'REGION',
    'SALES_CATEGORY_EPBCS',
    'CUSTOMER',
    'MODEL',
    'PROJECT',
    'VERSION',
    'Scenario',
    'Year',
    'Period',
    'Currency']
) }}


with source_data as
(
    SELECT
        _FileDate ,
        Account ,
        Entity ,
        UD1 ,
        UD2 ,
        UD3 ,
        UD4 ,
        UD5 ,
        UD6 ,
        UD7 ,
        UD8 ,
        Scenario ,
        Year ,
        Period ,
        Currency ,
        Amount
    FROM {{ source("FILE", "FORECASTBUDGET_EPBCS") }}
)
,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.
        _FILEDATE AS _FileDate,
        Account AS ACCOUNT_NUMBER_EPBCS,
        Entity AS SUBS,
        UD1 AS DEPARTMENT,
        UD2 AS SEGMENT,
        UD3 AS REGION,
        UD4 AS SALES_CATEGORY_EPBCS,
        UD5 AS CUSTOMER,
        UD6 AS MODEL,
        UD7 AS PROJECT,
        UD8 AS VERSION,
        SCENARIO AS SCENARIO,
        YEAR AS YEAR,
        PERIOD AS PERIOD,
        CURRENCY AS CURRENCY,
        AMOUNT AS AMOUNT						  
	FROM source_data
)
,type_data as
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(ACCOUNT_NUMBER_EPBCS AS VARCHAR(16777216)) AS ACCOUNT_NUMBER_EPBCS,
        cast(SUBS AS VARCHAR(16777216)) AS SUBS,
        cast(DEPARTMENT AS VARCHAR(16777216)) AS DEPARTMENT,
        cast(SEGMENT AS VARCHAR(16777216)) AS SEGMENT,
        cast(REGION AS VARCHAR(16777216)) AS REGION,
        cast(SALES_CATEGORY_EPBCS AS VARCHAR(16777216)) AS SALES_CATEGORY_EPBCS,
        cast(CUSTOMER AS VARCHAR(16777216)) AS CUSTOMER,
        cast(MODEL AS VARCHAR(16777216)) AS MODEL,
        cast(PROJECT AS VARCHAR(16777216)) AS PROJECT,
        cast(VERSION AS VARCHAR(16777216)) AS VERSION,
        cast(SCENARIO AS VARCHAR(16777216)) AS SCENARIO,
        cast(YEAR AS VARCHAR(16777216)) AS YEAR,
        cast(PERIOD AS VARCHAR(16777216)) AS PERIOD,
        cast(CURRENCY AS VARCHAR(16777216)) AS CURRENCY,
        cast(AMOUNT AS VARCHAR(16777216)) AS AMOUNT 
    from transform_data
    )
select * from type_data

