{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='SAPO_SYSTEM_STATUS',
        unique_key = ['ISTAT'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	ISTAT,
	NODIS,
	SETONLY
	FROM {{source('SAP_ORACLE_LIVE', 'TJ02')}}
),


transform_data as 
(
SELECT
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
    _CAPTUREDATETIME,
	ISTAT as ISTAT,
	NODIS as NODIS,
	SETONLY as SETONLY
	FROM SOURCE_DATA
), 

type_data as 
(
SELECT 
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
	ISTAT,
	NODIS,
	SETONLY
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA