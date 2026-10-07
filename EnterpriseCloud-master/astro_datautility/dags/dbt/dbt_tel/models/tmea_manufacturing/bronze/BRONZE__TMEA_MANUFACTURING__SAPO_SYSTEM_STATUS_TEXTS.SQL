{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='SAPO_SYSTEM_STATUS_TEXTS',
        unique_key = ['ISTAT',
    'SPRAS'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	ISTAT,
	SPRAS,
	TXT04,
	TXT30
	FROM {{source('SAP_ORACLE_LIVE', 'TJ02T')}}
),


transform_data as 
(
SELECT
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
    _CAPTUREDATETIME,
	ISTAT as ISTAT,
	SPRAS as SPRAS,
	TXT04 as TXT04,
	TXT30 as TXT30
	FROM SOURCE_DATA
), 

type_data as 
(
SELECT 
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
	ISTAT,
	SPRAS,
	TXT04,
	TXT30
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA