{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='GL_ACCOUNT_MASTER_RECORD',
        unique_key = ['CLIENT',
    'LANGUAGE_KEY',
    'CHART_OF_ACCOUNTS',
    'GL_ACCOUNT_NUMBER'],
        transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		SPRAS as LANGUAGE_KEY,
		KTOPL as CHART_OF_ACCOUNTS,
		SAKNR as GL_ACCOUNT_NUMBER,
		TXT20 as GL_ACCOUNT_SHORT_TEXT,
		TXT50 as GL_ACCOUNT_LONG_TEXT,
		MCOD1 as SEARCH_TERM_FOR_MATCHCODE_SEARCH,
		_CAPTUREDATETIME
    from {{ ref('BRONZE__TMEA_FINANCE__SAPO_GL_ACCOUNT_MASTER_RECORD') }}
),

transform_data as (
    select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		_CAPTUREDATETIME,
        CLIENT,
		LANGUAGE_KEY,
		CHART_OF_ACCOUNTS,
		GL_ACCOUNT_NUMBER,
		GL_ACCOUNT_SHORT_TEXT,
		GL_ACCOUNT_LONG_TEXT,
		SEARCH_TERM_FOR_MATCHCODE_SEARCH
    from source_data
),

type_data as (
    select
		cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(CLIENT as VARCHAR) as CLIENT,
		cast(LANGUAGE_KEY as VARCHAR) as LANGUAGE_KEY,
		cast(CHART_OF_ACCOUNTS as VARCHAR) as CHART_OF_ACCOUNTS,
		cast(GL_ACCOUNT_NUMBER as VARCHAR) as GL_ACCOUNT_NUMBER,
		cast(GL_ACCOUNT_SHORT_TEXT as VARCHAR) as GL_ACCOUNT_SHORT_TEXT,
		cast(GL_ACCOUNT_LONG_TEXT as VARCHAR) as GL_ACCOUNT_LONG_TEXT,
		cast(SEARCH_TERM_FOR_MATCHCODE_SEARCH as VARCHAR) as SEARCH_TERM_FOR_MATCHCODE_SEARCH
    from transform_data
)
select * from type_data