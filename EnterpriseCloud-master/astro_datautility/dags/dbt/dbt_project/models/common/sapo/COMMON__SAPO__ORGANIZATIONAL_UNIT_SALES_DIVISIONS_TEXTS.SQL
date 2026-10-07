{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='ORGANIZATIONAL_UNIT_SALES_DIVISIONS_TEXTS',
        unique_key = ['CLIENT',
    'LANGUAGE_KEY',
    'DIVISION'],
        transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		SPRAS as LANGUAGE_KEY,
		SPART as DIVISION,
		VTEXT as NAME,
		_CAPTUREDATETIME
    from {{ ref('ODS__SAPO__ORGANIZATIONAL_UNIT_SALES_DIVISIONS_TEXTS') }}
),

transform_data as (
    select
        CLIENT,
		LANGUAGE_KEY,
		DIVISION,
		NAME,
		_CAPTUREDATETIME,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH
    from source_data
),

type_data as (
    select
        cast(CLIENT as VARCHAR) as CLIENT,
		cast(LANGUAGE_KEY as VARCHAR) as LANGUAGE_KEY,
		cast(DIVISION as VARCHAR) as DIVISION,
		cast(NAME as VARCHAR) as NAME,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
		cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
)
select * from type_data