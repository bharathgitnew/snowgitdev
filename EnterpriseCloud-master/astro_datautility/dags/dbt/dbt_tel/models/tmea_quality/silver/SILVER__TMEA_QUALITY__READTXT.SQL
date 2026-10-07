{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='READTXT',
    	  unique_key = [''],
    	  transient=false	
) }} 


with source_data as ( 
    SELECT
        MANDT AS CLIENT,
        TDOBJECT AS TEXTS_APPLICATION_OBJECT,
        TDNAME AS NAME,
        TDID AS TEXT_ID,
        TDSPRAS AS LANGUAGE_KEY,
        LINE_NUMBER AS NATURAL_NUMBER,
        TDFDATE AS DATE_CREATED,
        TDFTIME AS TIME_CREATED,
        TDLDATE AS CHANGED_ON,
        TDLTIME AS LAST_CHANGED_AT,
        TDLINE AS TEXT_LINE,
        _CAPTUREDATETIME
    FROM {{ ref('BRONZE__TMEA_QUALITY__SAPO_READTXT') }}
),
	
transform_data as (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _CAPTUREDATETIME,
        CLIENT,
        TEXTS_APPLICATION_OBJECT,
        NAME,
        TEXT_ID,
        LANGUAGE_KEY,
        NATURAL_NUMBER,
        try_to_date(DATE_CREATED, 'YYYYMMDD') AS DATE_CREATED,
        TIME_CREATED,
        try_to_date(CHANGED_ON, 'YYYYMMDD') AS CHANGED_ON,
        LAST_CHANGED_AT,
        TEXT_LINE
    FROM source_data 
),

type_data as (
    SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
        CLIENT,
        TEXTS_APPLICATION_OBJECT,
        NAME,
        TEXT_ID,
        LANGUAGE_KEY,
        NATURAL_NUMBER,
        CAST(DATE_CREATED AS DATE) AS DATE_CREATED,
        TIME_CREATED,
        CAST(CHANGED_ON AS DATE) AS CHANGED_ON,
        LAST_CHANGED_AT,
        TEXT_LINE
    FROM transform_data 
)

select * from type_data