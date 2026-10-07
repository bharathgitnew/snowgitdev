/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='IPR_REASON',
	transient=false,
	tags=["IPR"]
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"REASON_ID"::NUMBER(38,10) AS REASON_ID,
		JSONFIELD:"DESCRIPTION"::VARCHAR AS DESCRIPTION,
		JSONFIELD:"SORT_ORDER"::NUMBER(38,10) AS SORT_ORDER
	FROM {{ source("IPR", "REASON") }}
WHERE
	_FILEDATE = (SELECT MAX(RUN_TIME) FROM {{ source('IPR', 'CONTROLTABLE') }} WHERE TABLE_NAME = 'REASON' ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		REASON_ID,
		DESCRIPTION,
		SORT_ORDER
	FROM source_data
),

type_data as (
	SELECT
		CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		CAST(REASON_ID AS NUMBER(38,10)) AS REASON_ID,
		DESCRIPTION,
		CAST(SORT_ORDER AS NUMBER(38,10)) AS SORT_ORDER
	FROM transform_data
)

SELECT * FROM type_data