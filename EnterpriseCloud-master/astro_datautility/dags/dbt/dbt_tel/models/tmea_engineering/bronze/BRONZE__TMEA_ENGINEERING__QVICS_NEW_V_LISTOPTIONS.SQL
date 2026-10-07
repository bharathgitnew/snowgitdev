/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='QVICS_NEW_V_LISTOPTIONS',
	transient=false,
	tags=["QVICS"]
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"ID"::NUMBER(38,10) AS ID,
		JSONFIELD:"ApplicationID"::NUMBER(38,10) AS APPLICATIONID,
		JSONFIELD:"UserID"::VARCHAR AS USERID,
		JSONFIELD:"Name"::VARCHAR AS NAME,
		JSONFIELD:"Value"::VARCHAR AS VALUE
	FROM {{ source("QVICS", "V_LISTOPTIONS") }}
WHERE
	_FILEDATE = (SELECT MAX(RUN_TIME) FROM {{ source('QVICS', 'CONTROLTABLE') }} WHERE TABLE_NAME ilike 'V_LISTOPTIONS' ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		ID,
		APPLICATIONID,
		USERID,
		NAME,
		VALUE
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
		CAST(APPLICATIONID AS NUMBER(38,10)) AS APPLICATIONID,
		USERID,
		NAME,
		VALUE
	FROM transform_data
)

SELECT * FROM type_data