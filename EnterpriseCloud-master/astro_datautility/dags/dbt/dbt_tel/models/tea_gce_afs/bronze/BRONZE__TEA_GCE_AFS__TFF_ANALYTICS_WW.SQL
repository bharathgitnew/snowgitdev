/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='TFF_ANALYTICS_WW',
	transient=false
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"id"::NUMBER(38,10) AS ID,
		JSONFIELD:"ww"::NUMBER(38,10) AS WW,
		REGEXP_REPLACE(JSONFIELD:"start_ww", '\/Date\\(|\\)\/', '')::TIMESTAMP_NTZ AS START_WW,
		REGEXP_REPLACE(JSONFIELD:"end_ww", '\/Date\\(|\\)\/', '')::TIMESTAMP_NTZ AS END_WW
	FROM {{ source("ADS", "TFF_ANALYTICS_WW") }}
WHERE
	_FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('ADS', 'TFF_ANALYTICS_WW') }} ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		ID,
		WW,
		START_WW,
		END_WW
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
		CAST(WW AS NUMBER(38,10)) AS WW,
		CAST(START_WW AS TIMESTAMP_NTZ) AS START_WW,
		CAST(END_WW AS TIMESTAMP_NTZ) AS END_WW
	FROM transform_data
)

SELECT * FROM type_data