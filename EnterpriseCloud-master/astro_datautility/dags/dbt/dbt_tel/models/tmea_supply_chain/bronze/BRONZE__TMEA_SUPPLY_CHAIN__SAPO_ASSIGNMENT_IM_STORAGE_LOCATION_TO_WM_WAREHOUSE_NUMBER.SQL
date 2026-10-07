{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='SAPO_ASSIGNMENT_IM_STORAGE_LOCATION_TO_WM_WAREHOUSE_NUMBER',
        unique_key = ['MANDT',
    'WERKS',
    'LGORT'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	WERKS,
	LGORT,
	LGNUM,
	OBEST,
	LGNTB,
	SLGOR,
	OBTYP,
	LGREF,
	CENSY
	FROM {{source('SAP_ORACLE_LIVE', 'T320')}}
),


transform_data as 
(
SELECT
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
    _CAPTUREDATETIME,
	MANDT as MANDT,
	WERKS as WERKS,
	LGORT as LGORT,
	LGNUM as LGNUM,
	OBEST as OBEST,
	LGNTB as LGNTB,
	SLGOR as SLGOR,
	OBTYP as OBTYP,
	LGREF as LGREF,
	CENSY as CENSY
	FROM SOURCE_DATA
), 

type_data as 
(
SELECT 
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
	MANDT,
	WERKS,
	LGORT,
	LGNUM,
	OBEST,
	LGNTB,
	SLGOR,
	OBTYP,
	LGREF,
	CENSY
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA