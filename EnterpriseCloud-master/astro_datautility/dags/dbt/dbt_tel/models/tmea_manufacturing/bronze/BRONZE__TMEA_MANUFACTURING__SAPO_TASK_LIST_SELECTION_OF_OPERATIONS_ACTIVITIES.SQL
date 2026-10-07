{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='SAPO_TASK_LIST_SELECTION_OF_OPERATIONS_ACTIVITIES',
    unique_key = ['MANDT',
	'PLNTY',
	'PLNNR',
	'PLNAL',
    'PLNFL',
	'PLNKN',
    'ZAEHL'],
    transient=false
) }}

with source_data as (
    select
        MANDT,
        PLNTY,
        PLNNR,
        PLNAL,
        PLNFL,
        PLNKN,
        ZAEHL,
        TRY_TO_DATE(DATUV,'YYYYMMDD') as DATUV,
        TECHV,
        AENNR,
        LOEKZ,
        PARKZ,
        TRY_TO_DATE(ANDAT,'YYYYMMDD') as ANDAT,
        ANNAM,
        TRY_TO_DATE(AEDAT,'YYYYMMDD') as AEDAT,
        AENAM,
		_CAPTUREDATETIME
    from {{source('SAP_ORACLE_LIVE','PLAS')}}
),

transform_data as (
    select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		MANDT,
        PLNTY,
        PLNNR,
        PLNAL,
        PLNFL,
        PLNKN,
        ZAEHL,
        DATUV,
        TECHV,
        AENNR,
        LOEKZ,
        PARKZ,
        ANDAT,
        ANNAM,
        AEDAT,
        AENAM,
		_CAPTUREDATETIME
    from source_data
),

type_data as (
    select
		CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
		CAST(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
		MANDT,
        PLNTY,
        PLNNR,
        PLNAL,
        PLNFL,
        PLNKN,
        ZAEHL,
        CAST(DATUV AS DATE) as DATUV,
        TECHV,
        AENNR,
        LOEKZ,
        PARKZ,
        CAST(ANDAT AS DATE) as ANDAT,
        ANNAM,
        CAST(AEDAT AS DATE) as AEDAT,
        AENAM
    from transform_data
)

select * from type_data