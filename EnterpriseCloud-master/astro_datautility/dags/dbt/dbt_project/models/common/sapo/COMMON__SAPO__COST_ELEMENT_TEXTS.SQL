{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='COST_ELEMENT_TEXTS',
        unique_key = ['CLIENT',
    'LANGUAGE_KEY',
    'CHART_OF_ACCOUNTS',
    'COST_ELEMENT'],
        transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		SPRAS as LANGUAGE_KEY,
		KTOPL as CHART_OF_ACCOUNTS,
		KSTAR as COST_ELEMENT,
		KTEXT as GENERAL_NAME,
		LTEXT as DESCRIPTION,
		MCTXT as SEARCH_TERM_FOR_MATCHCODE_USE,
		_CAPTUREDATETIME
    from {{ ref('ODS__SAPO__COST_ELEMENT_TEXTS') }}
),

transform_data as (
    select
        CLIENT,
		LANGUAGE_KEY,
		CHART_OF_ACCOUNTS,
		COST_ELEMENT,
		GENERAL_NAME,
		DESCRIPTION,
		SEARCH_TERM_FOR_MATCHCODE_USE,
		_CAPTUREDATETIME,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH
    from source_data
),

type_data as (
    select
        cast(CLIENT as VARCHAR(16777216)) as CLIENT,
		cast(LANGUAGE_KEY as VARCHAR(16777216)) as LANGUAGE_KEY,
		cast(CHART_OF_ACCOUNTS as VARCHAR(16777216)) as CHART_OF_ACCOUNTS,
		cast(COST_ELEMENT as VARCHAR(16777216)) as COST_ELEMENT,
		cast(GENERAL_NAME as VARCHAR(16777216)) as GENERAL_NAME,
		cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
		cast(SEARCH_TERM_FOR_MATCHCODE_USE as VARCHAR(16777216)) as SEARCH_TERM_FOR_MATCHCODE_USE,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
		cast(AUDIT_LOG_ID as VARCHAR(128)) as AUDIT_LOG_ID,
		cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH
    from transform_data
)
select * from type_data