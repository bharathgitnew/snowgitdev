{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='INFOTYPES',
        unique_key = ['MANDT',
    'INFTY'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	INFTY
	FROM {{source('SAP_ORACLE_LIVE', 'T778T')}}
),


transform_data as 
(
SELECT
    
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
	MANDT as MANDT,
	INFTY as INFTY,
	_CAPTUREDATETIME
	FROM SOURCE_DATA
), 

type_data as 
(
SELECT 
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	MANDT,
	INFTY,
	CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA