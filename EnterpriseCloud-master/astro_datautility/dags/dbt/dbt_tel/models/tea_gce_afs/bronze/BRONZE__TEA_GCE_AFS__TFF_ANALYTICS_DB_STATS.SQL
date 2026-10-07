/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='TFF_ANALYTICS_DB_STATS',
	transient=false
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"table_name"::VARCHAR AS TABLE_NAME,
		REGEXP_REPLACE(JSONFIELD:"latest_date", '\/Date\\(|\\)\/', '')::TIMESTAMP_NTZ AS LATEST_DATE,
		JSONFIELD:"latest_ww"::NUMBER(38,10) AS LATEST_WW,
		JSONFIELD:"rows"::NUMBER(38,10) AS "ROWS"
	FROM {{ source("ADS", "TFF_ANALYTICS_DB_STATS") }}
WHERE
	_FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('ADS', 'TFF_ANALYTICS_DB_STATS') }} ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		TABLE_NAME,
		LATEST_DATE,
		LATEST_WW,
		"ROWS"
	FROM source_data
),

type_data as (
	SELECT
		CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		TABLE_NAME,
		CAST(LATEST_DATE AS DATE) AS LATEST_DATE,
		CAST(LATEST_WW AS NUMBER(38,10)) AS LATEST_WW,
		CAST("ROWS" AS NUMBER(38,10)) AS "ROWS"
	FROM transform_data
)

SELECT * FROM type_data