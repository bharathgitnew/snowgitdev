{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='SHORT_DESCRIPTION_OF_SETS',
        unique_key = ['CLIENT',
    'SET_CLASS',
    'ORGANIZATIONAL_UNIT_AS_SET_SUBCLASS',
    'SET_NAME',
    'LANGUAGE_KEY'],
        transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		SETCLASS as SET_CLASS,
		SUBCLASS as ORGANIZATIONAL_UNIT_AS_SET_SUBCLASS,
		SETNAME as SET_NAME,
		LANGU as LANGUAGE_KEY,
		DESCRIPT as SHORT_DESCRIPTION_OF_A_SET,
		_CAPTUREDATETIME
    from {{ ref('BRONZE__TMEA_FINANCE__SAPO_SHORT_DESCRIPTION_OF_SETS') }}
),

transform_data as (
    select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		_CAPTUREDATETIME,
        CLIENT,
		SET_CLASS,
		ORGANIZATIONAL_UNIT_AS_SET_SUBCLASS,
		SET_NAME,
		LANGUAGE_KEY,
		SHORT_DESCRIPTION_OF_A_SET
    from source_data
),

type_data as (
    select
		cast(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(CLIENT as VARCHAR(16777216)) as CLIENT,
		cast(SET_CLASS as VARCHAR(16777216)) as SET_CLASS,
		cast(ORGANIZATIONAL_UNIT_AS_SET_SUBCLASS as VARCHAR(16777216)) as ORGANIZATIONAL_UNIT_AS_SET_SUBCLASS,
		cast(SET_NAME as VARCHAR(16777216)) as SET_NAME,
		cast(LANGUAGE_KEY as VARCHAR(16777216)) as LANGUAGE_KEY,
		cast(SHORT_DESCRIPTION_OF_A_SET as VARCHAR(16777216)) as SHORT_DESCRIPTION_OF_A_SET
    from transform_data
)
select * from type_data