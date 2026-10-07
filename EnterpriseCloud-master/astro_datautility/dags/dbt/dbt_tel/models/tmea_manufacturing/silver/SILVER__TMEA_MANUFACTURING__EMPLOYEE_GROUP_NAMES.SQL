{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='EMPLOYEE_GROUP_NAMES',
    unique_key = ['CLIENT','LANGUAGE_KEY','EMPLOYEE_GROUP'],
    transient=false
) }}

with source_data as (
    select
        CLIENT,
		LANGUAGE_KEY,
		EMPLOYEE_GROUP,
		NAME_OF_EMPLOYEE_GROUP,
		_CAPTUREDATETIME
    from {{ ref('BRONZE__TMEA_MANUFACTURING__SAPO_EMPLOYEE_GROUP_NAMES') }}
),

transform_data as (
    select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
        _CAPTUREDATETIME,
        CLIENT,
		LANGUAGE_KEY,
		EMPLOYEE_GROUP,
		NAME_OF_EMPLOYEE_GROUP
    from source_data
),

type_data as (
    select
		cast(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        CLIENT,
        LANGUAGE_KEY,
        EMPLOYEE_GROUP,
        NAME_OF_EMPLOYEE_GROUP
    from transform_data
)
select * from type_data