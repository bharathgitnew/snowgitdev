/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='TFF_ANALYTICS_BUCKET',
	transient=false
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"id"::NUMBER(38,10) AS ID,
		JSONFIELD:"bucket"::VARCHAR AS BUCKET,
		JSONFIELD:"sub_bucket"::VARCHAR AS SUB_BUCKET,
		JSONFIELD:"rank"::NUMBER(38,10) AS RANK
	FROM {{ source("ADS", "TFF_ANALYTICS_BUCKET") }}
WHERE
	_FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('ADS', 'TFF_ANALYTICS_BUCKET') }} ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		ID,
		BUCKET,
		SUB_BUCKET,
		RANK
	FROM source_data
),

type_data as (
	SELECT
		CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		CAST(ID AS NUMBER(38,10)) AS ID,
		BUCKET,
		SUB_BUCKET,
		CAST(RANK AS NUMBER(38,10)) AS RANK
	FROM transform_data
)

SELECT * FROM type_data