/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='MADATA_SILVER_NEW_DOWN_TOTAL_SPS',
	transient=false
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"WW"::VARCHAR AS WW,
		JSONFIELD:"ENTITY"::VARCHAR AS ENTITY,
		JSONFIELD:"CEID"::VARCHAR AS CEID,
		JSONFIELD:"Process Node"::VARCHAR AS PROCESS_NODE,
		JSONFIELD:"Location"::VARCHAR AS LOCATION,
		JSONFIELD:"Type"::VARCHAR AS TYPE,
		JSONFIELD:"New_Down_Total"::VARCHAR AS NEW_DOWN_TOTAL
	FROM {{ source("ADS", "MADATA_SILVER_NEW_DOWN_TOTAL_SPS") }}
WHERE
	_FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('ADS', 'MADATA_SILVER_NEW_DOWN_TOTAL_SPS') }} ) 
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
		CEID,
		PROCESS_NODE,
		LOCATION,
		TYPE,
		NEW_DOWN_TOTAL
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
		CEID,
		PROCESS_NODE,
		LOCATION,
		TYPE,
		NEW_DOWN_TOTAL
	FROM transform_data
)

SELECT * FROM type_data