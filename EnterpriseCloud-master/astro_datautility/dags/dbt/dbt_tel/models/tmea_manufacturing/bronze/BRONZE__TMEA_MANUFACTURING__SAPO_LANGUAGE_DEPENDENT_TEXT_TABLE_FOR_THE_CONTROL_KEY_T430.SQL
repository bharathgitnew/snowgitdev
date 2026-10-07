{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='SAPO_LANGUAGE_DEPENDENT_TEXT_TABLE_FOR_THE_CONTROL_KEY_T430',
    unique_key = ['CLIENT','LANGUAGE_KEY','APPLICATION_OF_THE_TASK_LIST','CONTROL_KEY'],
    transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		SPRAS as LANGUAGE_KEY,
		PLNAW as APPLICATION_OF_THE_TASK_LIST,
		STEUS as CONTROL_KEY,
		TXT as CONTROL_KEY_DESCRIPTION,
		_CAPTUREDATETIME
    from {{source('SAP_ORACLE_LIVE', 'T430T')}}
),

transform_data as (
    select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		_CAPTUREDATETIME,
        CLIENT,
		LANGUAGE_KEY,
		APPLICATION_OF_THE_TASK_LIST,
		CONTROL_KEY,
		CONTROL_KEY_DESCRIPTION
    from source_data
),

type_data as (
    select
		cast(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        CLIENT,
	 	LANGUAGE_KEY,
	 	APPLICATION_OF_THE_TASK_LIST,
	 	CONTROL_KEY,
	 	CONTROL_KEY_DESCRIPTION
    from transform_data
)
select * from type_data