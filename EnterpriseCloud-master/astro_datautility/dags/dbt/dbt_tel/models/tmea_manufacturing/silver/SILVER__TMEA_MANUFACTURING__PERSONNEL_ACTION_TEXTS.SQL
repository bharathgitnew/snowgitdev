{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='PERSONNEL_ACTION_TEXTS',
        unique_key = ['CLIENT',
    'LANGUAGE_KEY',
    'ACTION_TYPE',],
        transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		SPRSL as LANGUAGE_KEY,
		MASSN as ACTION_TYPE,
		MNTXT as NAME_OF_ACTION_TYPE,
		_CAPTUREDATETIME
    from {{ ref('BRONZE__TMEA_MANUFACTURING__SAPO_PERSONNEL_ACTION_TEXTS') }}
),

transform_data as (
    select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		_CAPTUREDATETIME,
        CLIENT,
		LANGUAGE_KEY,
		ACTION_TYPE,
		NAME_OF_ACTION_TYPE
    from source_data
),

type_data as (
    select
		cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
		CLIENT,
		LANGUAGE_KEY,
		ACTION_TYPE,
		NAME_OF_ACTION_TYPE
    from transform_data
)
select * from type_data