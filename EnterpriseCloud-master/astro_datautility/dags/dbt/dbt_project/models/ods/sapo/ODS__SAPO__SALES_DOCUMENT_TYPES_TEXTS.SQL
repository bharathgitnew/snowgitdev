{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='SALES_DOCUMENT_TYPES_TEXTS',
        unique_key = ['MANDT',
    'SPRAS',
    'AUART'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	SPRAS,
	AUART,
	BEZEI,
	TXT_BUTTON
	FROM {{source('SAP_ORACLE_LIVE', 'TVAKT')}}
),


transform_data as 
(
SELECT
    _CAPTUREDATETIME,
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
	MANDT as MANDT,
	SPRAS as SPRAS,
	AUART as AUART,
	BEZEI as BEZEI,
	TXT_BUTTON as TXT_BUTTON
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
	AUART,
	BEZEI,
	TXT_BUTTON
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA