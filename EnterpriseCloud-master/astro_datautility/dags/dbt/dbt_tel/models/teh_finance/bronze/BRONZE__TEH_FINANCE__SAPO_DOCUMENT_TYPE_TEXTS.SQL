{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='SAPO_DOCUMENT_TYPE_TEXTS',
        unique_key = ['MANDT',
    'SPRAS',
    'BLART'],
        transient=false
) }}

with source_data as (
    select
        MANDT as MANDT,
		SPRAS as SPRAS,
		BLART as BLART,
		LTEXT as LTEXT,
		_CAPTUREDATETIME
    from {{source('SAP_ORACLE_LIVE', 'T003T')}}
),

transform_is_deleted as (
    select
        tgt.MANDT,
		tgt.SPRAS,
		tgt.BLART,
		tgt.LTEXT,
		tgt._CAPTUREDATETIME,
		tgt.AUDIT_LOG_ID,
		tgt._ROW_HASH
    from {{this}} tgt
    left join source_data src
    on tgt.MANDT=src.MANDT
	and tgt.SPRAS=src.SPRAS
	and tgt.BLART=src.BLART
	where src.MANDT is null
	and src.SPRAS is null
	and src.BLART is null
),

transform_data as (
    select
        MANDT,
		SPRAS,
		BLART,
		LTEXT,
		_CAPTUREDATETIME,
		'No' as IS_DELETED,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH
    from source_data
    union
    select
        MANDT,
		SPRAS,
		BLART,
		LTEXT,
		_CAPTUREDATETIME,
		'Yes' as IS_DELETED,
		AUDIT_LOG_ID,
		_ROW_HASH
    from transform_is_deleted
),

type_data as (
    select
        cast(MANDT as VARCHAR) as MANDT,
		cast(SPRAS as VARCHAR) as SPRAS,
		cast(BLART as VARCHAR) as BLART,
		cast(LTEXT as VARCHAR) as LTEXT,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
		cast(IS_DELETED as VARCHAR) as IS_DELETED,
		cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
)
select * from type_data

