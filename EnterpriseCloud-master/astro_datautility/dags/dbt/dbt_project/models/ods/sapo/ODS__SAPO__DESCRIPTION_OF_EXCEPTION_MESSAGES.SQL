{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='DESCRIPTION_OF_EXCEPTION_MESSAGES',
        unique_key = ['MANDT',
    'SPRAS',
    'AUSSL'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	SPRAS,
	AUSSL,
	AUSLT
	FROM {{source('SAP_ORACLE_LIVE', 'T458B')}}
),


transform_data as 
(
SELECT
    _CAPTUREDATETIME,
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
	MANDT as MANDT,
	SPRAS as SPRAS,
	AUSSL as AUSSL,
	AUSLT as AUSLT
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
	AUSSL,
	AUSLT
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA