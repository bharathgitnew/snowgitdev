/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='QVICS_NEW_V_LISTUSEFULS',
	transient=false,
	tags=["QVICS"]
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"ApplicationID"::NUMBER(38,10) AS APPLICATIONID,
		JSONFIELD:"ID"::NUMBER(38,10) AS ID,
		JSONFIELD:"QVICSID"::NUMBER(38,10) AS QVICSID,
		JSONFIELD:"Account"::VARCHAR AS ACCOUNT
	FROM {{ source("QVICS", "V_LISTUSEFULS") }}
WHERE
	_FILEDATE = (SELECT MAX(RUN_TIME) FROM {{ source('QVICS', 'CONTROLTABLE') }} WHERE TABLE_NAME ilike 'V_LISTUSEFULS' ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		APPLICATIONID,
		ID,
		QVICSID,
		ACCOUNT
	FROM source_data
),

type_data as (
	SELECT
		CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		CAST(APPLICATIONID AS NUMBER(38,10)) AS APPLICATIONID,
		CAST(ID AS NUMBER(38,10)) AS ID,
		CAST(QVICSID AS NUMBER(38,10)) AS QVICSID,
		ACCOUNT
	FROM transform_data
)

SELECT * FROM type_data