{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='TIME_TYPES',
        unique_key = ['MANDT',
    'MOBDE',
    'ZTART',
    'ENDDA'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	MOBDE,
	ZTART,
	ENDDA,
	BEGDA,
	MOSUM,
	VORMO,
	EISUM,
	JAUEB,
	SAKOR,
	ZTNXP,
	ZTNXY,
	B1SUM
	FROM {{source('SAP_ORACLE_LIVE', 'T555A')}}
),


transform_data as 
(
SELECT
    _CAPTUREDATETIME,
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
	MANDT as MANDT,
	MOBDE as MOBDE,
	ZTART as ZTART,
	ENDDA as ENDDA,
	BEGDA as BEGDA,
	MOSUM as MOSUM,
	VORMO as VORMO,
	EISUM as EISUM,
	JAUEB as JAUEB,
	SAKOR as SAKOR,
	ZTNXP as ZTNXP,
	ZTNXY as ZTNXY,
	B1SUM as B1SUM
	FROM SOURCE_DATA
), 

type_data as 
(
SELECT 
	CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	MANDT,
	MOBDE,
	ZTART,
	ENDDA,
	BEGDA,
	MOSUM,
	VORMO,
	EISUM,
	JAUEB,
	SAKOR,
	ZTNXP,
	ZTNXY,
	B1SUM
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA