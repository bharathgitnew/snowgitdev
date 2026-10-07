{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='POSITION_TEXTS',
        unique_key = ['MANDT',
    'SPRSL',
    'OTYPE',
    'PLANS',
    'ENDDA',],
        transient=false
) }}

with source_data as (
SELECT 
    MANDT,
    SPRSL,
    OTYPE,
    PLANS,
    ENDDA,
    BEGDA,
    PLSTX,
    MAINT,
    _CAPTUREDATETIME
FROM {{source('SAP_ORACLE_LIVE', 'T528T')}}
),
transform_data as 
(
SELECT
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
	MANDT as MANDT,
    SPRSL as SPRSL,
    OTYPE as OTYPE,
    PLANS as PLANS,
    ENDDA as ENDDA,
    BEGDA as BEGDA,
    PLSTX as PLSTX,
    MAINT as MAINT,
    _CAPTUREDATETIME
	FROM SOURCE_DATA
), 

type_data as 
(
SELECT 
	_AUDIT_LOG_ID,
	_ROW_HASH,
	MANDT,
    SPRSL,
    OTYPE,
    CAST(PLANS AS NUMBER(38,0)) AS PLANS,
    CAST(ENDDA AS TIMESTAMP_LTZ(9)) AS ENDDA,
    CAST(BEGDA AS TIMESTAMP_LTZ(9)) AS BEGDA,
    PLSTX,
    MAINT,
    CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA