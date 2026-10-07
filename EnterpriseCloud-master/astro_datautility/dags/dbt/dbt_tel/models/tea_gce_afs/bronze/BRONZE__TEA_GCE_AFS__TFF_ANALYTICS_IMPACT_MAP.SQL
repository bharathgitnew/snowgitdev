/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='TFF_ANALYTICS_IMPACT_MAP',
	transient=false
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"id"::NUMBER(38,10) AS ID,
		JSONFIELD:"bucket_id"::NUMBER(38,10) AS BUCKET_ID,
		JSONFIELD:"comment_string"::VARCHAR AS COMMENT_STRING,
		JSONFIELD:"mom_impact"::VARCHAR AS MOM_IMPACT,
		JSONFIELD:"response_team"::VARCHAR AS RESPONSE_TEAM,
		JSONFIELD:"owner"::VARCHAR AS OWNER,
		JSONFIELD:"action"::VARCHAR AS ACTION,
		JSONFIELD:"user"::VARCHAR AS USER,
		REGEXP_REPLACE(JSONFIELD:"date", '\/Date\\(|\\)\/', '')::TIMESTAMP_NTZ AS DATE
	FROM {{ source("ADS", "TFF_ANALYTICS_IMPACT_MAP") }}
WHERE
	_FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('ADS', 'TFF_ANALYTICS_IMPACT_MAP') }} ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		ID,
		BUCKET_ID,
		COMMENT_STRING,
		MOM_IMPACT,
		RESPONSE_TEAM,
		OWNER,
		ACTION,
		USER,
		DATE
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
		CAST(BUCKET_ID AS NUMBER(38,10)) AS BUCKET_ID,
		COMMENT_STRING,
		MOM_IMPACT,
		RESPONSE_TEAM,
		OWNER,
		ACTION,
		USER,
		CAST(DATE AS TIMESTAMP_NTZ) AS DATE
	FROM transform_data
)

SELECT * FROM type_data