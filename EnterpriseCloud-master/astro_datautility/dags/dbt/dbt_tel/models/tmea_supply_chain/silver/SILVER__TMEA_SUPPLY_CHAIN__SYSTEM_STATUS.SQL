{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='SYSTEM_STATUS',
        unique_key = ['SYSTEM_STATUS'],
        transient=false
) }}

with source_data as (
    select
        ISTAT as SYSTEM_STATUS,
		NODIS as DO_NOT_DISPLAY_STATUS_FLAG,
		SETONLY as STATUS_CAN_ONLY_BE_SET_FLAG,
		_CAPTUREDATETIME
    from {{ ref('BRONZE__TMEA_SUPPLY_CHAIN__SAPO_SYSTEM_STATUS') }}
),

transform_data as (
    select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		_CAPTUREDATETIME,
        SYSTEM_STATUS,
		DO_NOT_DISPLAY_STATUS_FLAG,
		STATUS_CAN_ONLY_BE_SET_FLAG
    from source_data
),

type_data as (
    select
		cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(SYSTEM_STATUS as VARCHAR) as SYSTEM_STATUS,
		cast(DO_NOT_DISPLAY_STATUS_FLAG as VARCHAR) as DO_NOT_DISPLAY_STATUS_FLAG,
		cast(STATUS_CAN_ONLY_BE_SET_FLAG as VARCHAR) as STATUS_CAN_ONLY_BE_SET_FLAG
    from transform_data
)
select * from type_data