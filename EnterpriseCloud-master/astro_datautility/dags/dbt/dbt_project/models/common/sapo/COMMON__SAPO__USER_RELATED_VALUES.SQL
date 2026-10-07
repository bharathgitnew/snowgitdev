{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='USER_RELATED_VALUES',
        unique_key = ['CLIENT',
    'OBJECT_TYPE_PROGRAM_CLASS',
    'OBJECT_NAME_PARAMETER',
    'USER_NAME'],
        transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		OTYPE as OBJECT_TYPE_PROGRAM_CLASS,
		ONAME as OBJECT_NAME_PARAMETER,
		UNAME as USER_NAME,
		XUVAL as USER_VALUES,
		_CAPTUREDATETIME
    from {{ ref('ODS__SAPO__USER_RELATED_VALUES') }}
),

transform_data as (
    select
        CLIENT,
		OBJECT_TYPE_PROGRAM_CLASS,
		OBJECT_NAME_PARAMETER,
		USER_NAME,
		USER_VALUES,
		_CAPTUREDATETIME,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH
    from source_data
),

type_data as (
    select
        cast(CLIENT as VARCHAR) as CLIENT,
		cast(OBJECT_TYPE_PROGRAM_CLASS as VARCHAR) as OBJECT_TYPE_PROGRAM_CLASS,
		cast(OBJECT_NAME_PARAMETER as VARCHAR) as OBJECT_NAME_PARAMETER,
		cast(USER_NAME as VARCHAR) as USER_NAME,
		cast(USER_VALUES as VARCHAR) as USER_VALUES,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
		cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
)
select * from type_data