{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='SAPO_PURCHASING_GROUPS',
    unique_key = ['MANDT',
    'EKGRP']
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	EKGRP,
	EKNAM,
	EKTEL,
	LDEST,
	TELFX,
	TEL_NUMBER,
	TEL_EXTENS,
	SMTP_ADDR
	FROM {{ source("SAP_ORACLE_LIVE", "T024") }}
        
        )
,
    transform_data as 
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        _CAPTUREDATETIME,
		MANDT as MANDT,
		EKGRP as EKGRP,
		EKNAM as EKNAM,
		EKTEL as EKTEL,
		LDEST as LDEST,
		TELFX as TELFX,
		TEL_NUMBER as TEL_NUMBER,
		TEL_EXTENS as TEL_EXTENS,
		SMTP_ADDR as SMTP_ADDR
	FROM SOURCE_DATA
    ), 

    type_data as 
    (
    SELECT 
    	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
    	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
    	CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
		MANDT,
		EKGRP,
		EKNAM,
		EKTEL,
		LDEST,
		TELFX,
		TEL_NUMBER,
		TEL_EXTENS,
		SMTP_ADDR
FROM TRANSFORM_DATA
    )
 
    SELECT * FROM TYPE_DATA