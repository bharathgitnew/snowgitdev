{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='LANGUAGE_DEPENDENT_TEXTS_FOR_TABLE_TQ15',
        unique_key = ['CLIENT',
    'LANGUAGE_KEY',
    'CATALOG'],
        transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		SPRACHE as LANGUAGE_KEY,
		KATALOGART as CATALOG,
		KATALOGTXT as SHORT_TEXT_FOR_THE_CATALOG,
		SCHLAGWORT as KEYWORD_FOR_CATALOG_TYPE,
		_CAPTUREDATETIME
    from {{ ref('ODS__SAPO__LANGUAGE_DEPENDENT_TEXTS_FOR_TABLE_TQ15') }}
),

transform_data as (
    select
        CLIENT,
		LANGUAGE_KEY,
		CATALOG,
		SHORT_TEXT_FOR_THE_CATALOG,
		KEYWORD_FOR_CATALOG_TYPE,
		_CAPTUREDATETIME,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH
    from source_data
),

type_data as (
    select
        cast(CLIENT as VARCHAR) as CLIENT,
		cast(LANGUAGE_KEY as VARCHAR) as LANGUAGE_KEY,
		cast(CATALOG as VARCHAR) as CATALOG,
		cast(SHORT_TEXT_FOR_THE_CATALOG as VARCHAR) as SHORT_TEXT_FOR_THE_CATALOG,
		cast(KEYWORD_FOR_CATALOG_TYPE as VARCHAR) as KEYWORD_FOR_CATALOG_TYPE,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
		cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
)
select * from type_data