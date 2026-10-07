/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='IPR_CONTACT',
	transient=false,
	tags=["IPR"]
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"CONTACT_TYPE"::VARCHAR AS CONTACT_TYPE,
		JSONFIELD:"EMAIL_FROM"::VARCHAR AS EMAIL_FROM,
		JSONFIELD:"EMAIL_TO"::VARCHAR AS EMAIL_TO,
		JSONFIELD:"EMAIL_CC"::VARCHAR AS EMAIL_CC,
		JSONFIELD:"EMAIL_BCC"::VARCHAR AS EMAIL_BCC
	FROM {{ source("IPR", "CONTACT") }}
WHERE
	_FILEDATE = (SELECT MAX(RUN_TIME) FROM {{ source('IPR', 'CONTROLTABLE') }} WHERE TABLE_NAME = 'CONTACT' ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		CONTACT_TYPE,
		EMAIL_FROM,
		EMAIL_TO,
		EMAIL_CC,
		EMAIL_BCC
	FROM source_data
),

type_data as (
	SELECT
		CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		CONTACT_TYPE,
		EMAIL_FROM,
		EMAIL_TO,
		EMAIL_CC,
		EMAIL_BCC
	FROM transform_data
)

SELECT * FROM type_data