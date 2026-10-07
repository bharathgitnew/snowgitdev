{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='DOCUMENT_TYPE_TEXTS',
        unique_key = ['CLIENT',
    'LANGUAGE_KEY',
    'DOCUMENT_TYPE'],
        transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		SPRAS as LANGUAGE_KEY,
		BLART as DOCUMENT_TYPE,
		LTEXT as DOCUMENT_TYPE_DESCRIPTION,
		_CAPTUREDATETIME,
		IS_DELETED
    from {{ ref('ODS__SAPO__DOCUMENT_TYPE_TEXTS') }}
),

transform_data as (
    select
        CLIENT,
		LANGUAGE_KEY,
		DOCUMENT_TYPE,
		DOCUMENT_TYPE_DESCRIPTION,
		_CAPTUREDATETIME,
		IS_DELETED,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH
    from source_data
),

type_data as (
    select
        cast(CLIENT as VARCHAR) as CLIENT,
		cast(LANGUAGE_KEY as VARCHAR) as LANGUAGE_KEY,
		cast(DOCUMENT_TYPE as VARCHAR) as DOCUMENT_TYPE,
		cast(DOCUMENT_TYPE_DESCRIPTION as VARCHAR) as DOCUMENT_TYPE_DESCRIPTION,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
		cast(IS_DELETED as VARCHAR) as IS_DELETED,
		cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
)
select * from type_data