/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='MADATA_SILVER_PMA_COUNTSES',
	transient=false
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"ENTITY"::VARCHAR AS ENTITY,
		JSONFIELD:"WW"::FLOAT AS WW,
		JSONFIELD:"PMA Wafer Count"::FLOAT AS PMA_WAFER_COUNT
	FROM {{ source("ADS", "MADATA_SILVER_PMA_COUNTSES") }}
WHERE
	_FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('ADS', 'MADATA_SILVER_PMA_COUNTSES') }} ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		ENTITY,
		WW,
		PMA_WAFER_COUNT
	FROM source_data
),

type_data as (
	SELECT
		CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		ENTITY,
		CAST(WW AS FLOAT) AS WW,
		CAST(PMA_WAFER_COUNT AS FLOAT) AS PMA_WAFER_COUNT
	FROM transform_data
)

SELECT * FROM type_data