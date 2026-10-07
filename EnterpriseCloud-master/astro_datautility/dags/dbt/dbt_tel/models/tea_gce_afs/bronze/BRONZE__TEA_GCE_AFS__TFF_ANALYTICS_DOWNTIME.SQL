/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='TFF_ANALYTICS_DOWNTIME',
	transient=false
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"id"::NUMBER(38,10) AS ID,
		JSONFIELD:"entity_id"::NUMBER(38,10) AS ENTITY_ID,
		REGEXP_REPLACE(JSONFIELD:"down_date", '\/Date\\(|\\)\/', '')::TIMESTAMP_NTZ AS DOWN_DATE,
		REGEXP_REPLACE(JSONFIELD:"up_date", '\/Date\\(|\\)\/', '')::TIMESTAMP_NTZ AS UP_DATE
	FROM {{ source("ADS", "TFF_ANALYTICS_DOWNTIME") }}
WHERE
	_FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('ADS', 'TFF_ANALYTICS_DOWNTIME') }} ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		ID,
		ENTITY_ID,
		DOWN_DATE,
		UP_DATE
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
		CAST(ENTITY_ID AS NUMBER(38,10)) AS ENTITY_ID,
		CAST(DOWN_DATE AS TIMESTAMP_NTZ) AS DOWN_DATE,
		CAST(UP_DATE AS TIMESTAMP_NTZ) AS UP_DATE
	FROM transform_data
)

SELECT * FROM type_data