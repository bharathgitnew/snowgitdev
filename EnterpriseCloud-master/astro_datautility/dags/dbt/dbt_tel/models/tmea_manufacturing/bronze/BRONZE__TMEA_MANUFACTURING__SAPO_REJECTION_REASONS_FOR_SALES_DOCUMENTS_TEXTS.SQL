{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='SAPO_REJECTION_REASONS_FOR_SALES_DOCUMENTS_TEXTS',
        unique_key = ['MANDT',
    'SPRAS',
    'ABGRU'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	SPRAS,
	ABGRU,
	BEZEI
	FROM {{source('SAP_ORACLE_LIVE', 'TVAGT')}}
),


transform_data as 
(
SELECT
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
    _CAPTUREDATETIME,
	MANDT as MANDT,
	SPRAS as SPRAS,
	ABGRU as ABGRU,
	BEZEI as BEZEI
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
	ABGRU,
	BEZEI
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA