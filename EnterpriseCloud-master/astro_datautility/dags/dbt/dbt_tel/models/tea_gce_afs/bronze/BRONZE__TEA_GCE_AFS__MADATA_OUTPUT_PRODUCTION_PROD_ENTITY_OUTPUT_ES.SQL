/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='MADATA_OUTPUT_PRODUCTION_PROD_ENTITY_OUTPUT_ES',
	transient=false,
	tags=["MADATA_OUTPUT_PRODUCTION"]
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"ID"::NUMBER(38,10) AS ID,
		JSONFIELD:"ENTITY"::VARCHAR AS ENTITY
	FROM {{ source("ADS", "PROD_ENTITY_OUTPUT_ES") }}
WHERE
	_FILEDATE = (SELECT MAX(RUN_TIME) FROM {{ source('ADS', 'CONTROLTABLE') }} WHERE TABLE_NAME = 'Prod_ENTITY_Output_ES' ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		ID,
		ENTITY
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
		ENTITY
	FROM transform_data
)

SELECT * FROM type_data