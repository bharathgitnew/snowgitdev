{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='PUBLIC_HOLIDAY_TEXTS',
        unique_key = ['PUBLIC_HOLIDAY_KEY','LANGUAGE_KEY'],
        transient=false
) }}

with source_data as (
    select
		_CAPTUREDATETIME,
        FTGID AS PUBLIC_HOLIDAY_KEY,
        SPRAS AS LANGUAGE_KEY,
        LTEXT AS LONG_TEXT,
        KTEXT AS PUBLIC_HOLIDAYS_SHORT_TEXT   
    from {{ ref('ODS__SAPO__PUBLIC_HOLIDAY_TEXTS') }}
),

transform_data as (
    select
		_CAPTUREDATETIME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
        PUBLIC_HOLIDAY_KEY,
        LANGUAGE_KEY,
        LONG_TEXT,
        PUBLIC_HOLIDAYS_SHORT_TEXT
    from source_data
),

type_data as (
    select
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
		cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        PUBLIC_HOLIDAY_KEY,
        LANGUAGE_KEY,
        LONG_TEXT,
        PUBLIC_HOLIDAYS_SHORT_TEXT
    from transform_data
)
select * from type_data