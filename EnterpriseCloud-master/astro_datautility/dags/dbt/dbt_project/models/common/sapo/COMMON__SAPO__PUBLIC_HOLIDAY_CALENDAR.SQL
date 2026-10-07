{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='PUBLIC_HOLIDAY_CALENDAR',
        unique_key = ['PUBLIC_HOLIDAY_CALENDAR','DATE','PUBLIC_HOLIDAY_KEY'],
        transient=false
) }}

with source_data as (
    select
		_CAPTUREDATETIME,
        IDENT AS PUBLIC_HOLIDAY_CALENDAR,
        TRY_TO_DATE(DATUM,'YYYYMMDD') AS DATE,
        FTGID AS PUBLIC_HOLIDAY_KEY,
        GARANT AS PUBLIC_HOLIDAY_GUARANTEED_FLAG
    from {{ ref('ODS__SAPO__PUBLIC_HOLIDAY_CALENDAR') }}
),

transform_data as (
    SELECT
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
        _CAPTUREDATETIME,
        PUBLIC_HOLIDAY_CALENDAR,
        DATE,
        PUBLIC_HOLIDAY_KEY,
        PUBLIC_HOLIDAY_GUARANTEED_FLAG
    from source_data
),

type_data as (
    select
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
		cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        PUBLIC_HOLIDAY_CALENDAR,
        DATE,
        PUBLIC_HOLIDAY_KEY,
        PUBLIC_HOLIDAY_GUARANTEED_FLAG
    from transform_data
)
select * from type_data