{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='COST_CENTER_TEXTS',
        unique_key = ['CLIENT',
    'LANGUAGE_KEY',
    'CONTROLLING_AREA',
    'COST_CENTER',
    'VALID_TO_DATE'],
        transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		SPRAS as LANGUAGE_KEY,
		KOKRS as CONTROLLING_AREA,
		KOSTL as COST_CENTER,
		DATBI as VALID_TO_DATE,
		KTEXT as GENERAL_NAME,
		LTEXT as DESCRIPTION,
		MCTXT as SEARCH_TERM_FOR_MATCHCODE_USE,
		_CAPTUREDATETIME
    from {{ ref('BRONZE__TMEA_MANUFACTURING__SAPO_COST_CENTER_TEXTS') }}
),

transform_data as (
    select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		_CAPTUREDATETIME,
        CLIENT,
		LANGUAGE_KEY,
		CONTROLLING_AREA,
		COST_CENTER,
		TRY_TO_DATE(VALID_TO_DATE, 'YYYYMMDD') as VALID_TO_DATE,
		GENERAL_NAME,
		DESCRIPTION,
		SEARCH_TERM_FOR_MATCHCODE_USE
    from source_data
),

type_data as (
    select
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        CLIENT,
		LANGUAGE_KEY,
		CONTROLLING_AREA,
		COST_CENTER,
		cast(VALID_TO_DATE as DATE) as VALID_TO_DATE,
		GENERAL_NAME,
		DESCRIPTION,
		SEARCH_TERM_FOR_MATCHCODE_USE
    from transform_data
)
select * from type_data