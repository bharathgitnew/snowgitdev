{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias='SAPO_TMEA_WORK_CALENDAR',
        unique_key = ['MANDT',
    'PERIODAT'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	PERIODAT
	FROM {{source('SAP_ORACLE_LIVE', 'ZMMTFACTDAYS')}}
),


transform_data as 
(
SELECT
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
    _CAPTUREDATETIME,
	MANDT as MANDT,
	TRY_TO_DATE(PERIODAT, 'YYYYMMDD') as PERIODAT
	FROM SOURCE_DATA
), 

type_data as 
(
SELECT 
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
	MANDT,
	CAST(PERIODAT AS DATE) AS PERIODAT
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA