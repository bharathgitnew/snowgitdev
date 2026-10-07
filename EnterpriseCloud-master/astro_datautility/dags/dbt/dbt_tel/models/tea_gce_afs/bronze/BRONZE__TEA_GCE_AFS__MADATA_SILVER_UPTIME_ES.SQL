/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='MADATA_SILVER_UPTIME_ES',
	transient=false
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"ENTITY"::VARCHAR AS ENTITY,
		REGEXP_REPLACE(JSONFIELD:"Up_Date", '\/Date\\(|\\)\/', '')::TIMESTAMP_NTZ AS UP_DATE,
		REGEXP_REPLACE(JSONFIELD:"Down_Date", '\/Date\\(|\\)\/', '')::TIMESTAMP_NTZ AS DOWN_DATE
	FROM {{ source("ADS", "MADATA_SILVER_UPTIME_ES") }}
WHERE
	_FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('ADS', 'MADATA_SILVER_UPTIME_ES') }} ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		ENTITY,
		UP_DATE,
		DOWN_DATE
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
		CAST(UP_DATE AS TIMESTAMP_NTZ) AS UP_DATE,
		CAST(DOWN_DATE AS TIMESTAMP_NTZ) AS DOWN_DATE
	FROM transform_data
)

SELECT * FROM type_data