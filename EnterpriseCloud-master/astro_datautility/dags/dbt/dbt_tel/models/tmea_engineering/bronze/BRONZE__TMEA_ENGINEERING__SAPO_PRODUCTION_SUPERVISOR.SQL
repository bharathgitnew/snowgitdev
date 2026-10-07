{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='SAPO_PRODUCTION_SUPERVISOR',
        unique_key = ['MANDT',
    'WERKS',
    'FEVOR'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	WERKS,
	FEVOR,
	TXT,
	SFCPF
	FROM {{source('SAP_ORACLE_LIVE', 'T024F')}}
),


transform_data as 
(
SELECT
    _CAPTUREDATETIME,
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
	MANDT as MANDT,
	WERKS as WERKS,
	FEVOR as FEVOR,
	TXT as TXT,
	SFCPF as SFCPF
	FROM SOURCE_DATA
), 

type_data as 
(
SELECT 
	CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	MANDT,
	WERKS,
	FEVOR,
	TXT,
	SFCPF
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA