/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='TFF_ANALYTICS_RAW_COMMENTS',
	transient=false
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"FAB"::VARCHAR AS FAB,
		REGEXP_REPLACE(JSONFIELD:"TXN_DATE", '\/Date\\(|\\)\/', '')::TIMESTAMP_NTZ AS TXN_DATE,
		JSONFIELD:"ENTITY"::VARCHAR AS ENTITY,
		JSONFIELD:"COMMENTS"::VARCHAR AS COMMENTS
	FROM {{ source("ADS", "TFF_ANALYTICS_RAW_COMMENTS") }}
WHERE
	_FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('ADS', 'TFF_ANALYTICS_RAW_COMMENTS') }} ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		FAB,
		TXN_DATE,
		ENTITY,
		COMMENTS
	FROM source_data
),

type_data as (
	SELECT
		CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		FAB,
		CAST(TXN_DATE AS TIMESTAMP_NTZ) AS TXN_DATE,
		ENTITY,
		COMMENTS
	FROM transform_data
)

SELECT * FROM type_data