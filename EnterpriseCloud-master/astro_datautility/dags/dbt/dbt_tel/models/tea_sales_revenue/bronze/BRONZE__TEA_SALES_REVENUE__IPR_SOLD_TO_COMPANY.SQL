/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='IPR_SOLD_TO_COMPANY',
	transient=false,
	tags=["IPR"]
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"COMPANY_CODE"::VARCHAR AS COMPANY_CODE,
		JSONFIELD:"PARTNER"::VARCHAR AS PARTNER
	FROM {{ source("IPR", "SOLD_TO_COMPANY") }}
WHERE
	_FILEDATE = (SELECT MAX(RUN_TIME) FROM {{ source('IPR', 'CONTROLTABLE') }} WHERE TABLE_NAME = 'SOLD_TO_COMPANY' ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		COMPANY_CODE,
		PARTNER
	FROM source_data
),

type_data as (
	SELECT
		CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		COMPANY_CODE,
		PARTNER
	FROM transform_data
)

SELECT * FROM type_data