{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='MENU_SCREEN_MODIFICATIONS',
        unique_key = ['MANDT',
    'DYMOD',
    'SEQNR'],
        transient=false
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	DYMOD,
	SEQNR,
	DYFLD,
	REQUI,
	NOINP,
	INVSB,
	INTEN
	FROM {{source('SAP_ORACLE_LIVE', 'T77S3')}}
),


transform_data as 
(
SELECT
    _CAPTUREDATETIME,
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
	MANDT as MANDT,
	DYMOD as DYMOD,
	SEQNR as SEQNR,
	DYFLD as DYFLD,
	REQUI as REQUI,
	NOINP as NOINP,
	INVSB as INVSB,
	INTEN as INTEN
	FROM SOURCE_DATA
), 

type_data as 
(
SELECT 
	CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	MANDT,
	DYMOD,
	SEQNR,
	DYFLD,
	REQUI,
	NOINP,
	INVSB,
	INTEN
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA