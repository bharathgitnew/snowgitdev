{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='SAPO_MATERIAL_DESCRIPTIONS',
    unique_key = ['MANDT',
    'MATNR',
    'SPRAS']
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	MATNR,
	SPRAS,
	MAKTX,
	MAKTG
	FROM {{ source("SAP_ORACLE_LIVE", "MAKT") }}
        
)
,
transform_data as 
(
    SELECT
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
    _CAPTUREDATETIME,
	MANDT as MANDT,
	MATNR as MATNR,
	SPRAS as SPRAS,
	MAKTX as MAKTX,
	MAKTG as MAKTG
	FROM SOURCE_DATA
), 

type_data as 
(
    SELECT 
    CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
    CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
    CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
	CAST(MANDT AS varchar(16777216)) AS MANDT,
	CAST(MATNR AS varchar(16777216)) AS MATNR,
	CAST(SPRAS AS varchar(16777216)) AS SPRAS,
	CAST(MAKTX AS varchar(16777216)) AS MAKTX,
	CAST(MAKTG AS varchar(16777216)) AS MAKTG
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA