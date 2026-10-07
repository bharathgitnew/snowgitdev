-- copied from TMEA_SUPPLY_CHAIN
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='SAPO_BOMS_ITEM_SELECTION',
    unique_key = ['MANDT','STLTY','STLNR','STLAL','STLKN','STASZ'],
    transient=false
) }}

with source_data as (
    select
        MANDT as MANDT,
		STLTY as STLTY,
		STLNR as STLNR,
		STLAL as STLAL,
		STLKN as STLKN,
		STASZ as STASZ,
		DATUV as DATUV,
		TECHV as TECHV,
		AENNR as AENNR,
		LKENZ as LKENZ,
		ANDAT as ANDAT,
		ANNAM as ANNAM,
		AEDAT as AEDAT,
		AENAM as AENAM,
		DVDAT as DVDAT,
		DVNAM as DVNAM,
		AEHLP as AEHLP,
		STVKN as STVKN,
		IDPOS as IDPOS,
		IDVAR as IDVAR,
		LPSRT as LPSRT,
		_CAPTUREDATETIME
    from {{source('SAP_ORACLE_LIVE', 'STAS')}}
),

transform_is_deleted as (
    select
        tgt.MANDT,
		tgt.STLTY,
		tgt.STLNR,
		tgt.STLAL,
		tgt.STLKN,
		tgt.STASZ,
		tgt.DATUV,
		tgt.TECHV,
		tgt.AENNR,
		tgt.LKENZ,
		tgt.ANDAT,
		tgt.ANNAM,
		tgt.AEDAT,
		tgt.AENAM,
		tgt.DVDAT,
		tgt.DVNAM,
		tgt.AEHLP,
		tgt.STVKN,
		tgt.IDPOS,
		tgt.IDVAR,
		tgt.LPSRT,
		tgt._CAPTUREDATETIME,
		tgt._AUDIT_LOG_ID,
		tgt._ROW_HASH
    from {{this}} tgt
    left join source_data src
    on tgt.MANDT=src.MANDT
	and tgt.STLTY=src.STLTY
	and tgt.STLNR=src.STLNR
	and tgt.STLAL=src.STLAL
	and tgt.STLKN=src.STLKN
	and tgt.STASZ=src.STASZ
	where src.MANDT is null
	and src.STLTY is null
	and src.STLNR is null
	and src.STLAL is null
	and src.STLKN is null
	and src.STASZ is null
),

transform_data as (
    select
        MANDT,
		STLTY,
		STLNR,
		STLAL,
		STLKN,
		STASZ,
		DATUV,
		TECHV,
		AENNR,
		LKENZ,
		ANDAT,
		ANNAM,
		AEDAT,
		AENAM,
		DVDAT,
		DVNAM,
		AEHLP,
		STVKN,
		IDPOS,
		IDVAR,
		LPSRT,
		_CAPTUREDATETIME,
		'No' as IS_DELETED,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH
    from source_data
    union
    select
        MANDT,
		STLTY,
		STLNR,
		STLAL,
		STLKN,
		STASZ,
		DATUV,
		TECHV,
		AENNR,
		LKENZ,
		ANDAT,
		ANNAM,
		AEDAT,
		AENAM,
		DVDAT,
		DVNAM,
		AEHLP,
		STVKN,
		IDPOS,
		IDVAR,
		LPSRT,
		_CAPTUREDATETIME,
		'Yes' as IS_DELETED,
		_AUDIT_LOG_ID,
		_ROW_HASH
    from transform_is_deleted
),

type_data as (
    select
        cast(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
		MANDT,
		STLTY,
		STLNR,
		STLAL,
		STLKN,
		STASZ,
		DATUV,
		TECHV,
		AENNR,
		LKENZ,
		ANDAT,
		ANNAM,
		AEDAT,
		AENAM,
		DVDAT,
		DVNAM,
		AEHLP,
		STVKN,
		IDPOS,
		IDVAR,
		LPSRT,
		IS_DELETED
    from transform_data
)
select * from type_data