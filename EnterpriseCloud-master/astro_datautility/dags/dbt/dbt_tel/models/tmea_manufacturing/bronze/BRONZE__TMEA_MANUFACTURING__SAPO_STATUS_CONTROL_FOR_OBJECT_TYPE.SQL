{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='SAPO_STATUS_CONTROL_FOR_OBJECT_TYPE',
        unique_key = ['OBTYP',
    'ISTAT'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	OBTYP,
	ISTAT,
	INIST,
	LINEP,
	STATP
	FROM {{source('SAP_ORACLE_LIVE', 'TJ04')}}
),


transform_data as 
(
SELECT
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
    _CAPTUREDATETIME,
	OBTYP as OBTYP,
	ISTAT as ISTAT,
	INIST as INIST,
	LINEP as LINEP,
	STATP as STATP
	FROM SOURCE_DATA
), 

type_data as 
(
SELECT 
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
	OBTYP,
	ISTAT,
	INIST,
	LINEP,
	STATP
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA