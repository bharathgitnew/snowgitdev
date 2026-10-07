/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='TELCUSTOMER_REGION_MODEL',
	transient=false
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"BU"::VARCHAR AS BU,
		JSONFIELD:"MODEL_ID"::VARCHAR AS MODEL_ID,
		JSONFIELD:"MODEL_NAME"::VARCHAR AS MODEL_NAME,
		JSONFIELD:"TEL_REGION"::VARCHAR AS TEL_REGION
	FROM {{ source("TELCUSTOMER_DIVERSESYSTEMS", "REGION_MODEL") }}
WHERE
	_FILEDATE = (SELECT MAX(RUN_TIME) FROM {{ source('TELCUSTOMER_DIVERSESYSTEMS', 'CONTROLTABLE') }} WHERE TABLE_NAME = 'REGION_MODEL' ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		BU,
		MODEL_ID,
		MODEL_NAME,
		TEL_REGION
	FROM source_data
),

type_data as (
	SELECT
		CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		BU,
		MODEL_ID,
		MODEL_NAME,
		TEL_REGION
	FROM transform_data
)

SELECT * FROM type_data