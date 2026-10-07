{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='SAPO_MATERIAL_TO_BOM_LINK',
        unique_key = ['MANDT',
    'MATNR',
    'WERKS',
    'STLAN',
    'STLNR',
    'STLAL'],
        transient=false
) }}

with source_data as (
    select
		_CAPTUREDATETIME,
        MANDT as MANDT,
		MATNR as MATNR,
		WERKS as WERKS,
		STLAN as STLAN,
		STLNR as STLNR,
		STLAL as STLAL,
		LOSVN as LOSVN,
		LOSBS as LOSBS,
		ANDAT as ANDAT,
		ANNAM as ANNAM,
		AEDAT as AEDAT,
		AENAM as AENAM,
		CSLTY as CSLTY
    from {{source('SAP_ORACLE_LIVE', 'MAST')}}
),

transform_is_deleted as (
    select
		tgt._CAPTUREDATETIME,
		tgt._AUDIT_LOG_ID,
		tgt._ROW_HASH,
        tgt.MANDT,
		tgt.MATNR,
		tgt.WERKS,
		tgt.STLAN,
		tgt.STLNR,
		tgt.STLAL,
		tgt.LOSVN,
		tgt.LOSBS,
		tgt.ANDAT,
		tgt.ANNAM,
		tgt.AEDAT,
		tgt.AENAM,
		tgt.CSLTY
    from {{this}} tgt
    left join source_data src
    on tgt.MANDT=src.MANDT
	and tgt.MATNR=src.MATNR
	and tgt.WERKS=src.WERKS
	and tgt.STLAN=src.STLAN
	and tgt.STLNR=src.STLNR
	and tgt.STLAL=src.STLAL
	where src.MANDT is null
	and src.MATNR is null
	and src.WERKS is null
	and src.STLAN is null
	and src.STLNR is null
	and src.STLAL is null
),

transform_data as (
    select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		_CAPTUREDATETIME,
        MANDT,
		MATNR,
		WERKS,
		STLAN,
		STLNR,
		STLAL,
		LOSVN,
		LOSBS,
		ANDAT,
		ANNAM,
		AEDAT,
		AENAM,
		CSLTY,
		'No' as IS_DELETED
    from source_data
    union
    select
		_AUDIT_LOG_ID,
		_ROW_HASH,
		_CAPTUREDATETIME,
        MANDT,
		MATNR,
		WERKS,
		STLAN,
		STLNR,
		STLAL,
		LOSVN,
		LOSBS,
		ANDAT,
		ANNAM,
		AEDAT,
		AENAM,
		CSLTY,
		'Yes' as IS_DELETED
    from transform_is_deleted
),

type_data as (
    select
		cast(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        MANDT,
		MATNR,
		WERKS,
		STLAN,
		STLNR,
		STLAL,
		cast(LOSVN as NUMBER(38,10)) as LOSVN,
		cast(LOSBS as NUMBER(38,10)) as LOSBS,
		ANDAT,
		ANNAM,
		AEDAT,
		AENAM,
		CSLTY,
		IS_DELETED
    from transform_data
)
select * from type_data