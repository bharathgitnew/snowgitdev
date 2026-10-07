/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='IPR_CATEGORY_X_COMPANY',
	transient=false,
	tags=["IPR"]
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"CATEGORY_ID"::NUMBER(38,10) AS CATEGORY_ID,
		JSONFIELD:"COMPANY_CODE"::VARCHAR AS COMPANY_CODE,
		JSONFIELD:"GL_CODE"::VARCHAR AS GL_CODE
	FROM {{ source("IPR", "CATEGORY_X_COMPANY") }}
WHERE
	_FILEDATE = (SELECT MAX(RUN_TIME) FROM {{ source('IPR', 'CONTROLTABLE') }} WHERE TABLE_NAME = 'CATEGORY_X_COMPANY' ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		CATEGORY_ID,
		COMPANY_CODE,
		GL_CODE
	FROM source_data
),

type_data as (
	SELECT
		CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		CAST(CATEGORY_ID AS NUMBER(38,10)) AS CATEGORY_ID,
		COMPANY_CODE,
		GL_CODE
	FROM transform_data
)

SELECT * FROM type_data