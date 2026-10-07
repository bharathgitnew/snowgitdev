/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='IPR_DIMENSION',
	transient=false,
	tags=["IPR"]
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"DIM_TYPE"::NUMBER(38,0) AS DIM_TYPE,
		JSONFIELD:"DIM"::VARCHAR AS DIM,
		JSONFIELD:"DESCRIPTION"::VARCHAR AS DESCRIPTION,
		JSONFIELD:"ACTIVE"::NUMBER(38,0) AS ACTIVE
	FROM {{ source("IPR", "DIMENSION") }}
WHERE
	_FILEDATE = (SELECT MAX(RUN_TIME) FROM {{ source('IPR', 'CONTROLTABLE') }} WHERE TABLE_NAME = 'DIMENSION' ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		DIM_TYPE,
		DIM,
		DESCRIPTION,
		ACTIVE
	FROM source_data
),

type_data as (
	SELECT
		CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		CAST(DIM_TYPE AS NUMBER(38,0)) AS DIM_TYPE,
		DIM,
		DESCRIPTION,
		CAST(ACTIVE AS NUMBER(38,0)) AS ACTIVE
	FROM transform_data
)

SELECT * FROM type_data