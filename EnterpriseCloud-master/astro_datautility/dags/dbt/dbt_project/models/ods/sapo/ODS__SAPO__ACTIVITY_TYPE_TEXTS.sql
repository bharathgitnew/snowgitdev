

{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='ACTIVITY_TYPE_TEXTS',
    unique_key = ['MANDT','SPRAS','KOKRS','LSTAR','DATBI'],
    transient=false
) }}

with source_data as (
    select
        MANDT as MANDT,
		SPRAS as SPRAS,
		KOKRS as KOKRS,
		LSTAR as LSTAR,
		DATBI as DATBI,
		KTEXT as KTEXT,
		LTEXT as LTEXT,
		MCTXT as MCTXT,
		_CAPTUREDATETIME
    from {{source('SAP_ORACLE_LIVE', 'CSLT')}}
),

transform_data as (
    select
		_CAPTUREDATETIME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
        MANDT,
		SPRAS,
		KOKRS,
		LSTAR,
		DATBI,
		KTEXT,
		LTEXT,
		MCTXT
    from source_data
),

type_data as (
    select
	cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
	cast(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
	cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
	MANDT,
	SPRAS,
	KOKRS,
	LSTAR,
	DATBI,
	KTEXT,
	LTEXT,
	MCTXT
    from transform_data
)
select * from type_data