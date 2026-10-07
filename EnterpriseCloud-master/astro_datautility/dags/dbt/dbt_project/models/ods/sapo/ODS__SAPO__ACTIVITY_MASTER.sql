{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='ACTIVITY_MASTER',
    unique_key = ['MANDT','KOKRS','LSTAR','DATBI'],
    transient=false
) }}

with source_data as (
    select
        MANDT as MANDT,
		KOKRS as KOKRS,
		LSTAR as LSTAR,
		DATBI as DATBI,
		DATAB as DATAB,
		LEINH as LEINH,
		LATYP as LATYP,
		LATYPI as LATYPI,
		ERSDA as ERSDA,
		USNAM as USNAM,
		KSTTY as KSTTY,
		AUSEH as AUSEH,
		AUSFK as AUSFK,
		VKSTA as VKSTA,
		LARK1 as LARK1,
		LARK2 as LARK2,
		SPRKZ as SPRKZ,
		HRKFT as HRKFT,
		FIXVO as FIXVO,
		TARKZ as TARKZ,
		YRATE as YRATE,
		TARKZ_I as TARKZ_I,
		MANIST as MANIST,
		MANPLAN as MANPLAN,
		_CAPTUREDATETIME
    from {{source('SAP_ORACLE_LIVE', 'CSLA')}}
),

transform_data as (
    select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		_CAPTUREDATETIME,
        MANDT,
		KOKRS,
		LSTAR,
		DATBI,
		DATAB,
		LEINH,
		LATYP,
		LATYPI,
		ERSDA,
		USNAM,
		KSTTY,
		AUSEH,
		AUSFK,
		VKSTA,
		LARK1,
		LARK2,
		SPRKZ,
		HRKFT,
		FIXVO,
		TARKZ,
		YRATE,
		TARKZ_I,
		MANIST,
		MANPLAN
    from source_data
),

type_data as (
    select
    cast(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
	cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
	cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
	MANDT,
	KOKRS,
	LSTAR,
	DATBI,
	DATAB,
	LEINH,
	LATYP,
	LATYPI,
	ERSDA,
	USNAM,
	KSTTY,
	AUSEH,
	cast(AUSFK as NUMBER(38,10)) as AUSFK,
	VKSTA,
	LARK1,
	LARK2,
	SPRKZ,
	HRKFT,
	FIXVO,
	TARKZ,
	YRATE,
	TARKZ_I,
	MANIST,
	MANPLAN
    from transform_data
)
select * from type_data