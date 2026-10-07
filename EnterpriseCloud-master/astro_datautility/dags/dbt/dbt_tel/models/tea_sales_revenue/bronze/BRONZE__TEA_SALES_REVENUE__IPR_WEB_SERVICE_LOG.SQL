/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='IPR_WEB_SERVICE_LOG',
	transient=false,
	tags=["IPR"]
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"REQUEST_JSON"::VARIANT AS REQUEST_JSON,
		JSONFIELD:"EVENT_TYPE"::VARCHAR AS EVENT_TYPE,
		REGEXP_REPLACE(JSONFIELD:"EVENT_TIME", '\/Date\\(|\\)\/', '')::TIMESTAMP_NTZ AS EVENT_TIME
	FROM {{ source("IPR", "WEB_SERVICE_LOG") }}
WHERE
	_FILEDATE = (SELECT MAX(RUN_TIME) FROM {{ source('IPR', 'CONTROLTABLE') }} WHERE TABLE_NAME = 'WEB_SERVICE_LOG' ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		REQUEST_JSON,
		EVENT_TYPE,
		EVENT_TIME
	FROM source_data
),

type_data as (
	SELECT
		CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		REQUEST_JSON,
		EVENT_TYPE,
		CAST(EVENT_TIME AS TIMESTAMP_NTZ) AS EVENT_TIME
	FROM transform_data
)

SELECT * FROM type_data