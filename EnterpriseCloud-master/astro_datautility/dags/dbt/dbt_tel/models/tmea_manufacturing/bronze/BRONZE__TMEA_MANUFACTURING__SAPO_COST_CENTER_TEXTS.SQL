{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='SAPO_COST_CENTER_TEXTS',
        unique_key = ['MANDT',
    'SPRAS',
    'KOKRS',
    'KOSTL',
    'DATBI'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	SPRAS,
	KOKRS,
	KOSTL,
	DATBI,
	KTEXT,
	LTEXT,
	MCTXT
	FROM {{source('SAP_ORACLE_LIVE', 'CSKT')}}
),


transform_data as 
(
SELECT
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
    _CAPTUREDATETIME,
	MANDT as MANDT,
	SPRAS as SPRAS,
	KOKRS as KOKRS,
	KOSTL as KOSTL,
	DATBI as DATBI,
	KTEXT as KTEXT,
	LTEXT as LTEXT,
	MCTXT as MCTXT
	FROM SOURCE_DATA
), 

type_data as 
(
SELECT 
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
	MANDT,
	SPRAS,
	KOKRS,
	KOSTL,
	DATBI,
	KTEXT,
	LTEXT,
	MCTXT
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA