{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='MENU_SCREEN_MODIFICATIONS',
        unique_key = ['CLIENT',
    'SCREEN_MODIFICATION',
    'SEQUENCE_NUMBER'],
        transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		DYMOD as SCREEN_MODIFICATION,
		SEQNR as SEQUENCE_NUMBER,
		DYFLD as DYNPRO_FIELD_NAME,
		REQUI as REQUIRED_FIELD,
		NOINP as FIELD_NOT_READY_FOR_INPUT,
		INVSB as INVISIBLE_FIELD,
		INTEN as HIGHLIGHTED_FIELD,
		_CAPTUREDATETIME
    from {{ ref('ODS__SAPO__MENU_SCREEN_MODIFICATIONS') }}
),

transform_data as (
    select
        CLIENT,
		SCREEN_MODIFICATION,
		SEQUENCE_NUMBER,
		DYNPRO_FIELD_NAME,
		REQUIRED_FIELD,
		FIELD_NOT_READY_FOR_INPUT,
		INVISIBLE_FIELD,
		HIGHLIGHTED_FIELD,
		_CAPTUREDATETIME,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH
    from source_data
),

type_data as (
    select
        cast(CLIENT as VARCHAR) as CLIENT,
		cast(SCREEN_MODIFICATION as VARCHAR) as SCREEN_MODIFICATION,
		cast(SEQUENCE_NUMBER as VARCHAR) as SEQUENCE_NUMBER,
		cast(DYNPRO_FIELD_NAME as VARCHAR) as DYNPRO_FIELD_NAME,
		cast(REQUIRED_FIELD as VARCHAR) as REQUIRED_FIELD,
		cast(FIELD_NOT_READY_FOR_INPUT as VARCHAR) as FIELD_NOT_READY_FOR_INPUT,
		cast(INVISIBLE_FIELD as VARCHAR) as INVISIBLE_FIELD,
		cast(HIGHLIGHTED_FIELD as VARCHAR) as HIGHLIGHTED_FIELD,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
		cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
)
select * from type_data