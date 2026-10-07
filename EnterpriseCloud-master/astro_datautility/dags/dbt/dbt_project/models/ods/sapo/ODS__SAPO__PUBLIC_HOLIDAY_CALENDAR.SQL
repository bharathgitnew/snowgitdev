{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='PUBLIC_HOLIDAY_CALENDAR',
        unique_key = ['IDENT',
    'DATUM',
    'FTGID'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	IDENT,
    DATUM,
    FTGID,
    GARANT
	FROM {{source('SAP_ORACLE_LIVE', 'THOC')}}
),


transform_data as 
(
SELECT
    _CAPTUREDATETIME,
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
	IDENT,
    DATUM,
    FTGID,
    GARANT
	FROM SOURCE_DATA
), 

type_data as 
(
SELECT 
	CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	IDENT,
    DATUM,
    FTGID,
    GARANT
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA