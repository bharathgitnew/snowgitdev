{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='USER_MASTER_TEXTS_FOR_PROFILES_USR10',
        unique_key = ['MANDT',
    'LANGU',
    'PROFN',
    'AKTPS'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	LANGU,
	PROFN,
	AKTPS,
	PTEXT
	FROM {{source('SAP_ORACLE_LIVE', 'USR11')}}
),


transform_data as 
(
SELECT
    _CAPTUREDATETIME,
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
	MANDT as MANDT,
	LANGU as LANGU,
	PROFN as PROFN,
	AKTPS as AKTPS,
	PTEXT as PTEXT
	FROM SOURCE_DATA
), 

type_data as 
(
SELECT 
	CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	MANDT,
	LANGU,
	PROFN,
	AKTPS,
	PTEXT
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA