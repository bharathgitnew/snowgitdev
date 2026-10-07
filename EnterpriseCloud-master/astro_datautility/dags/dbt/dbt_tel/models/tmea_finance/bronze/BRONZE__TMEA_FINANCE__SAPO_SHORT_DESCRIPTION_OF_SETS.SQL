{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='SAPO_SHORT_DESCRIPTION_OF_SETS',
        unique_key = ['MANDT',
    'SETCLASS',
    'SUBCLASS',
    'SETNAME',
    'LANGU'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	SETCLASS,
	SUBCLASS,
	SETNAME,
	LANGU,
	DESCRIPT
	FROM {{source('SAP_ORACLE_LIVE', 'SETHEADERT')}}
),


transform_data as 
(
SELECT
    _CAPTUREDATETIME,
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
	MANDT as MANDT,
	SETCLASS as SETCLASS,
	SUBCLASS as SUBCLASS,
	SETNAME as SETNAME,
	LANGU as LANGU,
	DESCRIPT as DESCRIPT
	FROM SOURCE_DATA
), 

type_data as 
(
SELECT 
	CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	MANDT,
	SETCLASS,
	SUBCLASS,
	SETNAME,
	LANGU,
	DESCRIPT
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA