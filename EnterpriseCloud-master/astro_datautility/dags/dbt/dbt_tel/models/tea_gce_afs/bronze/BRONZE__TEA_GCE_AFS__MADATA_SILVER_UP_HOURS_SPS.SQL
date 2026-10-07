/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='MADATA_SILVER_UP_HOURS_SPS',
	transient=false
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"WW"::VARCHAR AS WW,
		JSONFIELD:"Location"::VARCHAR AS LOCATION,
		JSONFIELD:"Process Node"::VARCHAR AS PROCESS_NODE,
		JSONFIELD:"CEID"::VARCHAR AS CEID,
		JSONFIELD:"ENTITY"::VARCHAR AS ENTITY,
		JSONFIELD:"Total_Up_Hours"::FLOAT AS TOTAL_UP_HOURS
	FROM {{ source("ADS", "MADATA_SILVER_UP_HOURS_SPS") }}
WHERE
	_FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('ADS', 'MADATA_SILVER_UP_HOURS_SPS') }} ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		WW,
		LOCATION,
		PROCESS_NODE,
		CEID,
		ENTITY,
		TOTAL_UP_HOURS
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
		LOCATION,
		PROCESS_NODE,
		CEID,
		ENTITY,
		CAST(TOTAL_UP_HOURS AS FLOAT) AS TOTAL_UP_HOURS
	FROM transform_data
)

SELECT * FROM type_data