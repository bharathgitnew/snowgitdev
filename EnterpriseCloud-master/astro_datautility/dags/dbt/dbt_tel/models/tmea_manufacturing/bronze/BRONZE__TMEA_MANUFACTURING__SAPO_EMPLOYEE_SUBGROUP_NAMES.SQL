{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='SAPO_EMPLOYEE_SUBGROUP_NAMES',
    unique_key = ['CLIENT','LANGUAGE_KEY','EMPLOYEE_SUBGROUP'],
    transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		SPRSL as LANGUAGE_KEY,
		PERSK as EMPLOYEE_SUBGROUP,
		PTEXT as NAME_OF_EMPLOYEE_SUBGROUP,
		_CAPTUREDATETIME
    from {{source('SAP_ORACLE_LIVE','T503T')}}
),

transform_data as (
    select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		_CAPTUREDATETIME,
        CLIENT,
		LANGUAGE_KEY,
		EMPLOYEE_SUBGROUP,
		NAME_OF_EMPLOYEE_SUBGROUP
    from source_data
),

type_data as (
    select
	cast(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
	cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
	cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
    CLIENT,
	LANGUAGE_KEY,
	EMPLOYEE_SUBGROUP,
	NAME_OF_EMPLOYEE_SUBGROUP
	from transform_data
)
select * from type_data