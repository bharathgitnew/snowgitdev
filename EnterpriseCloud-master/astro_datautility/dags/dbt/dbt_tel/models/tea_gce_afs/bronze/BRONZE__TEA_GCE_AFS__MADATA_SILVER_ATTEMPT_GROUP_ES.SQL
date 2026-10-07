/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='MADATA_SILVER_ATTEMPT_GROUP_ES',
	transient=false
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"WW"::VARCHAR AS WW,
		JSONFIELD:"Node"::VARCHAR AS NODE,
		JSONFIELD:"CEID"::VARCHAR AS CEID,
		JSONFIELD:"Location"::VARCHAR AS LOCATION,
		JSONFIELD:"Bucket"::VARCHAR AS BUCKET,
		JSONFIELD:"Attempt_mean"::FLOAT AS ATTEMPT_MEAN,
		JSONFIELD:"13_week"::FLOAT AS "13_WEEK",
		JSONFIELD:"4_week"::FLOAT AS "4_WEEK"
	FROM {{ source("ADS", "MADATA_SILVER_ATTEMPT_GROUP_ES") }}
WHERE
	_FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('ADS', 'MADATA_SILVER_ATTEMPT_GROUP_ES') }} ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		WW,
		NODE,
		CEID,
		LOCATION,
		BUCKET,
		ATTEMPT_MEAN,
		"13_WEEK",
		"4_WEEK"
	FROM source_data
),

type_data as (
	SELECT
		CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		WW,
		NODE,
		CEID,
		LOCATION,
		BUCKET,
		CAST(ATTEMPT_MEAN AS FLOAT) AS ATTEMPT_MEAN,
		CAST("13_WEEK" AS FLOAT) AS "13_WEEK",
		CAST("4_WEEK" AS FLOAT) AS "4_WEEK"
	FROM transform_data
)

SELECT * FROM type_data