{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='SAPO_INDIVIDUAL_OBJECT_STATUS',
        unique_key = ['MANDT',
    'OBJNR',
    'STAT'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	OBJNR,
	STAT,
	INACT,
	CHGNR,
	_DATAAGING
	FROM {{source('SAP_ORACLE_LIVE', 'JEST')}}
),


transform_data as 
(
SELECT
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
    _CAPTUREDATETIME,
	MANDT as MANDT,
	OBJNR as OBJNR,
	STAT as STAT,
	INACT as INACT,
	CHGNR as CHGNR,
	_DATAAGING as DATAAGING
	FROM SOURCE_DATA
), 

type_data as 
(
SELECT 
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
	MANDT,
	OBJNR,
	STAT,
	INACT,
	CHGNR,
	DATAAGING
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA