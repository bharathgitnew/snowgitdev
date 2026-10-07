{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='QUOTA_FILE_HEADER',
        unique_key = ['MANDT',
    'MATNR',
    'WERKS',
    'BDATU'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	MATNR,
	WERKS,
	BDATU,
	VDATU,
	QUNUM,
	ERDAT,
	ERNAM,
	SCMNG
	FROM {{source('SAP_ORACLE_LIVE', 'EQUK')}}
),


transform_data as 
(
SELECT
    _CAPTUREDATETIME,
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
	MANDT as MANDT,
	MATNR as MATNR,
	WERKS as WERKS,
	BDATU as BDATU,
	VDATU as VDATU,
	QUNUM as QUNUM,
	ERDAT as ERDAT,
	ERNAM as ERNAM,
	SCMNG as SCMNG
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
	WERKS,
	BDATU,
	VDATU,
	QUNUM,
	ERDAT,
	ERNAM,
	CAST(SCMNG AS NUMBER(38,10)) AS SCMNG
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA