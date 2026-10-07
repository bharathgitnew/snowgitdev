{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='DEFINITION_OF_EVALUATION_PATHS',
        unique_key = ['MANDT',
    'WEGID',
    'WEGNR'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	WEGID,
	WEGNR,
	OTYPE,
	RSIGN,
	RELAT,
	PRIOX,
	SCLAS,
	SKIPF
	FROM {{source('SAP_ORACLE_LIVE', 'T77AW')}}
),


transform_data as 
(
SELECT
    _CAPTUREDATETIME,
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
	MANDT as MANDT,
	WEGID as WEGID,
	WEGNR as WEGNR,
	OTYPE as OTYPE,
	RSIGN as RSIGN,
	RELAT as RELAT,
	PRIOX as PRIOX,
	SCLAS as SCLAS,
	SKIPF as SKIPF
	FROM SOURCE_DATA
), 

type_data as 
(
SELECT 
	CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	MANDT,
	WEGID,
	WEGNR,
	OTYPE,
	RSIGN,
	RELAT,
	PRIOX,
	SCLAS,
	SKIPF
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA