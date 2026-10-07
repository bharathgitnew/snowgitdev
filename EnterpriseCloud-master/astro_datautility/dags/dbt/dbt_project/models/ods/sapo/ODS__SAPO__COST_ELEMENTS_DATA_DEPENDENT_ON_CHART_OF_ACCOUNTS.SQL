{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='COST_ELEMENTS_DATA_DEPENDENT_ON_CHART_OF_ACCOUNTS',
        unique_key = ['MANDT',
    'KTOPL',
    'KSTAR',
    'ERSDA',
    'USNAM',
    'STEKZ',
    'ZAHKZ',
    'KSTSN',
    'FUNC_AREA'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	KTOPL,
	KSTAR,
	ERSDA,
	USNAM,
	STEKZ,
	ZAHKZ,
	KSTSN,
	FUNC_AREA
	FROM {{source('SAP_ORACLE_LIVE', 'CSKA')}}
),


transform_data as 
(
SELECT
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
	MANDT as MANDT,
	KTOPL as KTOPL,
	KSTAR as KSTAR,
	ERSDA as ERSDA,
	USNAM as USNAM,
	STEKZ as STEKZ,
	ZAHKZ as ZAHKZ,
	KSTSN as KSTSN,
	FUNC_AREA as FUNC_AREA,
	_CAPTUREDATETIME
	FROM SOURCE_DATA
), 

type_data as 
(
SELECT 
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	MANDT,
	KTOPL,
	KSTAR,
	ERSDA,
	USNAM,
	STEKZ,
	ZAHKZ,
	KSTSN,
	FUNC_AREA,
	CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA