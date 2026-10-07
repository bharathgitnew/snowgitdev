{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='DESCRIPTION_OF_EXCEPTION_MESSAGES',
        unique_key = ['CLIENT',
    'LANGUAGE_KEY',
    'EXCEPTION_MESSAGE_KEY'],
        transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		SPRAS as LANGUAGE_KEY,
		AUSSL as EXCEPTION_MESSAGE_KEY,
		AUSLT as EXCEPTION_MESSAGE_TEXT,
		_CAPTUREDATETIME
    from {{ ref('ODS__SAPO__DESCRIPTION_OF_EXCEPTION_MESSAGES') }}
),

transform_data as (
    select
        CLIENT,
		LANGUAGE_KEY,
		EXCEPTION_MESSAGE_KEY,
		EXCEPTION_MESSAGE_TEXT,
		_CAPTUREDATETIME,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH
    from source_data
),

type_data as (
    select
        cast(CLIENT as VARCHAR) as CLIENT,
		cast(LANGUAGE_KEY as VARCHAR) as LANGUAGE_KEY,
		cast(EXCEPTION_MESSAGE_KEY as VARCHAR) as EXCEPTION_MESSAGE_KEY,
		cast(EXCEPTION_MESSAGE_TEXT as VARCHAR) as EXCEPTION_MESSAGE_TEXT,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
		cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
)
select * from type_data