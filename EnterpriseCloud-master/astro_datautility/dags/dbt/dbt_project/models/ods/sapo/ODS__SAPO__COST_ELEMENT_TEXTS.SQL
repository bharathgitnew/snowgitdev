{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='COST_ELEMENT_TEXTS',
        unique_key = ['MANDT',
    'SPRAS',
    'KTOPL',
    'KSTAR'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	SPRAS,
	KTOPL,
	KSTAR,
	KTEXT,
	LTEXT,
	MCTXT
	FROM {{source('SAP_ORACLE_LIVE', 'CSKU')}}
),


transform_data as 
(
SELECT
    _CAPTUREDATETIME,
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
	MANDT as MANDT,
	SPRAS as SPRAS,
	KTOPL as KTOPL,
	KSTAR as KSTAR,
	KTEXT as KTEXT,
	LTEXT as LTEXT,
	MCTXT as MCTXT
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
	KTOPL,
	KSTAR,
	KTEXT,
	LTEXT,
	MCTXT
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA