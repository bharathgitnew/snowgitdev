{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='USER_RELATED_VALUES',
        unique_key = ['MANDT',
    'OTYPE',
    'ONAME',
    'UNAME'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	OTYPE,
	ONAME,
	UNAME,
	XUVAL
	FROM {{source('SAP_ORACLE_LIVE', 'T513A')}}
),


transform_data as 
(
SELECT
    _CAPTUREDATETIME,
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
	MANDT as MANDT,
	OTYPE as OTYPE,
	ONAME as ONAME,
	UNAME as UNAME,
	XUVAL as XUVAL
	FROM SOURCE_DATA
), 

type_data as 
(
SELECT 
	CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	MANDT,
	OTYPE,
	ONAME,
	UNAME,
	XUVAL
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA