/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='MADATA_SILVER_STATES',
	transient=false
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"WW"::VARCHAR AS WW,
		JSONFIELD:"Entity"::VARCHAR AS ENTITY,
		JSONFIELD:"PrimaryDownReason"::VARCHAR AS PRIMARYDOWNREASON,
		JSONFIELD:"Time"::VARCHAR AS TIME,
		JSONFIELD:"TOTAL_HOURS"::VARCHAR AS TOTAL_HOURS,
		JSONFIELD:"%"::VARCHAR AS PERCENT,
		JSONFIELD:"Process"::VARCHAR AS PROCESS
	FROM {{ source("ADS", "MADATA_SILVER_STATES") }}
WHERE
	_FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('ADS', 'MADATA_SILVER_STATES') }} ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		WW,
		ENTITY,
		PRIMARYDOWNREASON,
		TIME,
		TOTAL_HOURS,
		PERCENT,
		PROCESS
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
		ENTITY,
		PRIMARYDOWNREASON,
		TIME,
		TOTAL_HOURS,
		PERCENT,
		PROCESS
	FROM transform_data
)

SELECT * FROM type_data