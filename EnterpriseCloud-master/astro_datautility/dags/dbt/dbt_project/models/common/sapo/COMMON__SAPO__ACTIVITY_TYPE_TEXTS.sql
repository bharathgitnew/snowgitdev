

{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='ACTIVITY_TYPE_TEXTS',
    unique_key = ['CLIENT','LANGUAGE_KEY','CONTROLLING_AREA','ACTIVITY_TYPE','VALID_TO_DATE'],
    transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		SPRAS as LANGUAGE_KEY,
		KOKRS as CONTROLLING_AREA,
		LSTAR as ACTIVITY_TYPE,
		DATBI as VALID_TO_DATE,
		KTEXT as GENERAL_NAME,
		LTEXT as DESCRIPTION,
		MCTXT as SEARCH_TERM_FOR_MATCHCODE_USE,
		_CAPTUREDATETIME
    from {{ ref('ODS__SAPO__ACTIVITY_TYPE_TEXTS') }}
),

transform_data as (
    select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
        CLIENT,
		LANGUAGE_KEY,
		CONTROLLING_AREA,
		ACTIVITY_TYPE,
		TRY_TO_DATE(VALID_TO_DATE, 'YYYYMMDD') as VALID_TO_DATE,
		GENERAL_NAME,
		DESCRIPTION,
		SEARCH_TERM_FOR_MATCHCODE_USE,
		_CAPTUREDATETIME
    from source_data
),

type_data as (
    select
	cast(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
	cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
	cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
	CLIENT,
	LANGUAGE_KEY,
	CONTROLLING_AREA,
	ACTIVITY_TYPE,
	cast(VALID_TO_DATE as DATE) as VALID_TO_DATE,
	GENERAL_NAME,
	DESCRIPTION,
	SEARCH_TERM_FOR_MATCHCODE_USE
    from transform_data
)
select * from type_data