{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='FILE_FORECASTBUDGET',
    unique_key = ['_FileDate',
    'Account',
    'Entity',
    'UD1',
    'UD2',
    'UD3',
    'UD4',
    'UD5',
    'UD6',
    'UD7',
    'UD8',
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
    FROM {{ source("FILE", "FORECASTBUDGET") }}
)
,transform_data as
(
    SELECT
        _FILEDATE AS _FileDate,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        ACCOUNT AS Account,
        ENTITY AS Entity,
        UD1 AS UD1,
        UD2 AS UD2,
        UD3 AS UD3,
        UD4 AS UD4,
        UD5 AS UD5,
        UD6 AS UD6,
        UD7 AS UD7,
        UD8 AS UD8,
        SCENARIO AS Scenario,
        YEAR AS Year,
        PERIOD AS Period,
        CURRENCY AS Currency,
        AMOUNT AS Amount
    FROM source_data
)
,type_data as
(
    select
    
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(ACCOUNT as VARCHAR(16777216)) as ACCOUNT,
        cast(ENTITY as VARCHAR(16777216)) as ENTITY,
        cast(UD1 as VARCHAR(16777216)) as UD1,
        cast(UD2 as VARCHAR(16777216)) as UD2,
        cast(UD3 as VARCHAR(16777216)) as UD3,
        cast(UD4 as VARCHAR(16777216)) as UD4,
        cast(UD5 as VARCHAR(16777216)) as UD5,
        cast(UD6 as VARCHAR(16777216)) as UD6,
        cast(UD7 as VARCHAR(16777216)) as UD7,
        cast(UD8 as VARCHAR(16777216)) as UD8,
        cast(SCENARIO as VARCHAR(16777216)) as SCENARIO,
        cast(YEAR as VARCHAR(16777216)) as YEAR,
        cast(PERIOD as VARCHAR(16777216)) as PERIOD,
        cast(CURRENCY as VARCHAR(16777216)) as CURRENCY,
        cast(AMOUNT as VARCHAR(16777216)) as AMOUNT
    from transform_data
    )
select * from type_data