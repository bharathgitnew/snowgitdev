/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='MADATA_SILVER_TOOL_LIST_WW_ES',
	transient=false
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"Location"::VARCHAR AS LOCATION,
		JSONFIELD:"Process Node"::VARCHAR AS PROCESS_NODE,
		JSONFIELD:"CEID"::VARCHAR AS CEID,
		JSONFIELD:"ENTITY"::VARCHAR AS ENTITY,
		JSONFIELD:"Type"::VARCHAR AS TYPE,
		JSONFIELD:"WW"::VARCHAR AS WW,
		JSONFIELD:"Include"::VARCHAR AS INCLUDE
	FROM {{ source("ADS", "MADATA_SILVER_TOOL_LIST_WW_ES") }}
WHERE
	_FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('ADS', 'MADATA_SILVER_TOOL_LIST_WW_ES') }} ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		LOCATION,
		PROCESS_NODE,
		CEID,
		ENTITY,
		TYPE,
		WW,
		INCLUDE
	FROM source_data
),

type_data as (
	SELECT
		CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		LOCATION,
		PROCESS_NODE,
		CEID,
		ENTITY,
		TYPE,
		WW,
		INCLUDE
	FROM transform_data
)

SELECT * FROM type_data