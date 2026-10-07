{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='SALES_DOCUMENT_TYPES_TEXTS',
        unique_key = ['CLIENT',
    'LANGUAGE_KEY',
    'SALES_DOCUMENT_TYPE'],
        transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		SPRAS as LANGUAGE_KEY,
		AUART as SALES_DOCUMENT_TYPE,
		BEZEI as DESCRIPTION,
		TXT_BUTTON as TEXT_ON_BROWSER_BUTTON,
		_CAPTUREDATETIME
    from {{ ref('ODS__SAPO__SALES_DOCUMENT_TYPES_TEXTS') }}
),

transform_data as (
    select
        CLIENT,
		LANGUAGE_KEY,
		SALES_DOCUMENT_TYPE,
		DESCRIPTION,
		TEXT_ON_BROWSER_BUTTON,
		_CAPTUREDATETIME,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH
    from source_data
),

type_data as (
    select
        cast(CLIENT as VARCHAR) as CLIENT,
		cast(LANGUAGE_KEY as VARCHAR) as LANGUAGE_KEY,
		cast(SALES_DOCUMENT_TYPE as VARCHAR) as SALES_DOCUMENT_TYPE,
		cast(DESCRIPTION as VARCHAR) as DESCRIPTION,
		cast(TEXT_ON_BROWSER_BUTTON as VARCHAR) as TEXT_ON_BROWSER_BUTTON,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
		cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
)
select * from type_data