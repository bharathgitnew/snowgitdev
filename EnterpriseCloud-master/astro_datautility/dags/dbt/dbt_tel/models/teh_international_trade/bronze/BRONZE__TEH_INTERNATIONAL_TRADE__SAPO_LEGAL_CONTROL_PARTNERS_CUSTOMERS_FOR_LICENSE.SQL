{{ config(
    alias='SAPO_LEGAL_CONTROL_PARTNERS_CUSTOMERS_FOR_LICENSE',
    incremental_strategy='merge',
    unique_key = ['MANDT','GEGRU','GEART','KUNNR','GENNR'],
) }}

with source_data as (
    select
		_CAPTUREDATETIME,
        MANDT AS MANDT,
        GEGRU AS GEGRU,
        GEART AS GEART,
        KUNNR AS KUNNR,
        GENNR AS GENNR,
        PARAG AS PARAG,
        PARWF AS PARWF,
        PARRS AS PARRS,
        PARRE AS PARRE,
        PAREN AS PAREN,
        PARR1 AS PARR1,
        PARR2 AS PARR2,
        PARR3 AS PARR3,
        VBDNR AS VBDNR,
        VBDFG AS VBDFG,
    from {{source('SAP_ORACLE_LIVE', 'T606Z')}}
),

transform_is_deleted as (
    select
		tgt._CAPTUREDATETIME,
		tgt._AUDIT_LOG_ID,
		tgt._ROW_HASH,
        tgt.MANDT,
        tgt.GEGRU,
        tgt.GEART,
        tgt.KUNNR,
        tgt.GENNR,
        tgt.PARAG,
        tgt.PARWF,
        tgt.PARRS,
        tgt.PARRE,
        tgt.PAREN,
        tgt.PARR1,
        tgt.PARR2,
        tgt.PARR3,
        tgt.VBDNR,
        tgt.VBDFG,
    from {{ this }} tgt
    left join source_data src
        on tgt.MANDT=src.MANDT
        and tgt.GEGRU = src.GEGRU
        and tgt.GEART = src.GEART
        and tgt.KUNNR = src.KUNNR
        and tgt.GENNR = src.GENNR
    where src.MANDT is null
        and src.GEGRU is null
        and src.GEART is null
        and src.KUNNR is null
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
        KUNNR,
        GENNR,
        PARAG,
        PARWF,
        PARRS,
        PARRE,
        PAREN,
        PARR1,
        PARR2,
        PARR3,
        VBDNR,
        VBDFG,
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
        KUNNR,
        GENNR,
        PARAG,
        PARWF,
        PARRS,
        PARRE,
        PAREN,
        PARR1,
        PARR2,
        PARR3,
        VBDNR,
        VBDFG,
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
        KUNNR,
        GENNR,
        PARAG,
        PARWF,
        PARRS,
        PARRE,
        PAREN,
        PARR1,
        PARR2,
        PARR3,
        VBDNR,
        VBDFG,
		IS_DELETED
    from transform_data
)

select * from type_data