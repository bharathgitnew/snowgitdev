{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='LEGAL_CONTROL_DESTINATION_COUNTRIES_FOR_LICENSE',
        unique_key = ['MANDT','GEGRU','GEART','GENLA','GENNR'],
        transient=false
) }}
with source_data as (
    select
		_CAPTUREDATETIME,
        MANDT AS MANDT,
        GEGRU AS GEGRU,
        GEART AS GEART,
        GENLA AS GENLA,
        GENNR AS GENNR,
    from {{source('SAP_ORACLE_LIVE', 'T606X')}}
),
transform_is_deleted as (
    select
		tgt._CAPTUREDATETIME,
		tgt._AUDIT_LOG_ID,
		tgt._ROW_HASH,
        tgt.MANDT,
        tgt.GEGRU,
        tgt.GEART,
        tgt.GENLA,
        tgt.GENNR
    from {{this}} tgt
    left join source_data src
    on tgt.MANDT=src.MANDT
	and tgt.GEGRU=src.GEGRU
	and tgt.GEART=src.GEART
	and tgt.GENLA=src.GENLA
	and tgt.GENNR=src.GENNR
	where src.MANDT is null
    and src.GEGRU is null
	and src.GEART is null
	and src.GENLA is null
	and src.GENNR is null
	
),

transform_data as (
    select
		_CAPTUREDATETIME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
        MANDT,
        GEGRU,
        GEART,
        GENLA,
        GENNR,
		'No' as IS_DELETED
    from source_data
    union
    select
		_CAPTUREDATETIME,
		_AUDIT_LOG_ID,
		_ROW_HASH,
        MANDT,
        GEGRU,
        GEART,
        GENLA,
        GENNR,
		'Yes' as IS_DELETED
    from transform_is_deleted
),

type_data as (
    select
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
		cast(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
        MANDT,
        GEGRU,
        GEART,
        GENLA,
        GENNR,
		IS_DELETED
    from transform_data
)
select * from type_data