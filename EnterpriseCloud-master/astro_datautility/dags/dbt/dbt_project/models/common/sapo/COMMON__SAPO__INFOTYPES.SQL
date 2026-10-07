{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='INFOTYPES',
        unique_key = ['CLIENT',
    'INFOTYPE'],
        transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		INFTY as INFOTYPE,
		_CAPTUREDATETIME
    from {{ ref('ODS__SAPO__INFOTYPES') }}
),

transform_data as (
    select
        CLIENT,
		INFOTYPE,
		_CAPTUREDATETIME,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH
    from source_data
),

type_data as (
    select
        cast(CLIENT as VARCHAR) as CLIENT,
		cast(INFOTYPE as VARCHAR) as INFOTYPE,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
		cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
)
select * from type_data