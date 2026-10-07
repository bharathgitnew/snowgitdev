{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAPO_READTXT',
    	  unique_key = [''],
    	  transient=false	
) }} 


with source_data as ( 
    SELECT
        _CAPTUREDATETIME,
    	MANDT,
        TDOBJECT,
        TDNAME,
        TDID,
        TDSPRAS,
        LINE_NUMBER,
        TDFDATE,
        TDFTIME,
        TDLDATE,
        TDLTIME,
        TDLINE
    FROM {{ source('SAP_ORACLE_LIVE','ZSTXH_READTXT') }}	
),
	
transform_data as (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _CAPTUREDATETIME,
		MANDT,
        TDOBJECT,
        TDNAME,
        TDID,
        TDSPRAS,
        LINE_NUMBER,
        TDFDATE,
        TDFTIME,
        TDLDATE,
        TDLTIME,
        TDLINE
    FROM source_data 
),

type_data as (
    SELECT
        CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
		CAST(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
		MANDT,
        TDOBJECT,
        TDNAME,
        TDID,
        TDSPRAS,
        CAST(LINE_NUMBER AS NUMBER(38,10)) AS LINE_NUMBER,
        TDFDATE,
        TDFTIME,
        TDLDATE,
        TDLTIME,
        TDLINE
    FROM transform_data 
)

select * from type_data