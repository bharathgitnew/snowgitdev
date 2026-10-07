/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='IPR_V_ADDRESS',
	transient=false,
	tags=["IPR"]
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"addrnumber"::VARCHAR AS ADDRNUMBER,
		JSONFIELD:"name"::VARCHAR AS NAME,
		JSONFIELD:"address"::VARCHAR AS ADDRESS,
		JSONFIELD:"city"::VARCHAR AS CITY,
		JSONFIELD:"state"::VARCHAR AS STATE,
		JSONFIELD:"country"::VARCHAR AS COUNTRY,
		JSONFIELD:"zip"::VARCHAR AS ZIP,
		REGEXP_REPLACE(JSONFIELD:"last_updated_dt", '\/Date\\(|\\)\/', '')::TIMESTAMP_NTZ AS LAST_UPDATED_DT
	FROM {{ source("IPR", "V_ADDRESS") }}
WHERE
	_FILEDATE = (SELECT MAX(RUN_TIME) FROM {{ source('IPR', 'CONTROLTABLE') }} WHERE TABLE_NAME = 'v_address' ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		ADDRNUMBER,
		NAME,
		ADDRESS,
		CITY,
		STATE,
		COUNTRY,
		ZIP,
		LAST_UPDATED_DT
	FROM source_data
),

type_data as (
	SELECT
		CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		ADDRNUMBER,
		NAME,
		ADDRESS,
		CITY,
		STATE,
		COUNTRY,
		ZIP,
		CAST(LAST_UPDATED_DT AS TIMESTAMP_NTZ) AS LAST_UPDATED_DT
	FROM transform_data
)

SELECT * FROM type_data