{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='SAPO_MASTER_WARRANTY_OBJECT_ASSIGNMENT',
        unique_key = ['MANDT',
    'J_OBJNR',
    'GAART'],
        transient=false
) }} 

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	J_OBJNR,
	GAART,
	MGANR,
	GWLDT,
	GWLEN,
	ERDAT,
	ERZEI,
	LVORM,
	BEGRU,
	GENER,
	GAERB,
	WAGET
	FROM {{ source("SAP_ORACLE_LIVE", "BGMKOBJ") }}
),


transform_data as 
(
    SELECT
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
    _CAPTUREDATETIME,
	MANDT as MANDT,
	J_OBJNR as J_OBJNR,
	GAART as GAART,
	MGANR as MGANR,
	GWLDT as GWLDT,
	GWLEN as GWLEN,
	ERDAT as ERDAT,
	ERZEI as ERZEI,
	LVORM as LVORM,
	BEGRU as BEGRU,
	GENER as GENER,
	GAERB as GAERB,
	WAGET as WAGET
	FROM SOURCE_DATA
), 

type_data as 
(
    SELECT 
    CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
    CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
    CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
	MANDT,
	J_OBJNR,
	GAART,
	MGANR,
	GWLDT,
	GWLEN,
	ERDAT,
	ERZEI,
	LVORM,
	BEGRU,
	GENER,
	GAERB,
	WAGET
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA