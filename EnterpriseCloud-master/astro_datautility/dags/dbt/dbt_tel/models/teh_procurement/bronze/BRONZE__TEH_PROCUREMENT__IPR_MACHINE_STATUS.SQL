/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='IPR_MACHINE_STATUS',
	transient=false,
	tags=["IPR"]
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"MACHINE_STATUS_ID"::NUMBER(38,0) AS MACHINE_STATUS_ID,
		JSONFIELD:"DESCRIPTION"::VARCHAR AS DESCRIPTION
	FROM {{ source("IPR", "MACHINE_STATUS") }}
WHERE
	_FILEDATE = (SELECT MAX(RUN_TIME) FROM {{ source('IPR', 'CONTROLTABLE') }} WHERE TABLE_NAME = 'MACHINE_STATUS' ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		MACHINE_STATUS_ID,
		DESCRIPTION
	FROM source_data
),

type_data as (
	SELECT
		CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		CAST(MACHINE_STATUS_ID AS NUMBER(38,0)) AS MACHINE_STATUS_ID,
		DESCRIPTION
	FROM transform_data
)

SELECT * FROM type_data