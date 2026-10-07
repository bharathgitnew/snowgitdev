/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='QVICS_NEW_V_TROUBLE_COMPONENTLISTS',
	transient=false,
	tags=["QVICS"]
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"TroubleID"::NUMBER(38,10) AS TROUBLEID,
		JSONFIELD:"componentList"::VARCHAR AS COMPONENTLIST
	FROM {{ source("QVICS", "V_TROUBLE_COMPONENTLISTS") }}
WHERE
	_FILEDATE = (SELECT MAX(RUN_TIME) FROM {{ source('QVICS', 'CONTROLTABLE') }} WHERE TABLE_NAME ilike 'V_TROUBLE_COMPONENTLISTS' ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		TROUBLEID,
		COMPONENTLIST
	FROM source_data
),

type_data as (
	SELECT
		CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		CAST(TROUBLEID AS NUMBER(38,10)) AS TROUBLEID,
		COMPONENTLIST
	FROM transform_data
)

SELECT * FROM type_data