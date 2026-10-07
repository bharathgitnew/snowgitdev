{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias='TMEA_WORK_CALENDAR',
        unique_key = ['CLIENT',
    'DATE'],
        transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		PERIODAT as DATE,
		_CAPTUREDATETIME
    from {{ ref('BRONZE__TMEA_MANUFACTURING__SAPO_TMEA_WORK_CALENDAR') }}
),

transform_data as (
    select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
		_CAPTUREDATETIME,
        CLIENT,
		DATE
    from source_data
),

type_data as (
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(CLIENT as VARCHAR) as CLIENT,
		cast(DATE as DATE) as DATE
    from transform_data
)
select * from type_data