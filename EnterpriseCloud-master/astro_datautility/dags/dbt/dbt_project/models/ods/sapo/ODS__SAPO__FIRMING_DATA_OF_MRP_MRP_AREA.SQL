{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='FIRMING_DATA_OF_MRP_MRP_AREA',
        unique_key = ['MANDT',
    'MATNR',
    'BERID',
    'PLSCN'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	MATNR,
	BERID,
	PLSCN,
	OPFDT,
	MFXDT,
	MFNAM,
	MFDAT
	FROM {{source('SAP_ORACLE_LIVE', 'MDFDDB')}}
),


transform_data as 
(
SELECT
    _CAPTUREDATETIME,
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
	MANDT as MANDT,
	MATNR as MATNR,
	BERID as BERID,
	PLSCN as PLSCN,
	OPFDT as OPFDT,
	MFXDT as MFXDT,
	MFNAM as MFNAM,
	MFDAT as MFDAT
	FROM SOURCE_DATA
), 

type_data as 
(
SELECT 
	CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	MANDT,
	MATNR,
	BERID,
	PLSCN,
	OPFDT,
	MFXDT,
	MFNAM,
	MFDAT
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA