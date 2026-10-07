{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='ORGANIZATIONAL_UNIT_SALES_DIVISIONS_TEXTS',
        unique_key = ['MANDT',
    'SPRAS',
    'SPART'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	SPRAS,
	SPART,
	VTEXT
	FROM {{source('SAP_ORACLE_LIVE', 'TSPAT')}}
),


transform_data as 
(
SELECT
    _CAPTUREDATETIME,
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
	MANDT as MANDT,
	SPRAS as SPRAS,
	SPART as SPART,
	VTEXT as VTEXT
	FROM SOURCE_DATA
), 

type_data as 
(
SELECT 
	CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	MANDT,
	SPRAS,
	SPART,
	VTEXT
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA