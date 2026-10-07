/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='IPR_SHIPPING_ROUTE',
	transient=false,
	tags=["IPR"]
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"ROUTE"::VARCHAR AS ROUTE,
		JSONFIELD:"DESCRIPTION"::VARCHAR AS DESCRIPTION,
		JSONFIELD:"SORT_ORDER"::NUMBER(38,0) AS SORT_ORDER,
		JSONFIELD:"ACTIVE"::NUMBER(38,0) AS ACTIVE
	FROM {{ source("IPR", "SHIPPING_ROUTE") }}
WHERE
	_FILEDATE = (SELECT MAX(RUN_TIME) FROM {{ source('IPR', 'CONTROLTABLE') }} WHERE TABLE_NAME = 'SHIPPING_ROUTE' ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		ROUTE,
		DESCRIPTION,
		SORT_ORDER,
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
		ROUTE,
		DESCRIPTION,
		CAST(SORT_ORDER AS NUMBER(38,0)) AS SORT_ORDER,
		CAST(ACTIVE AS NUMBER(38,0)) AS ACTIVE
	FROM transform_data
)

SELECT * FROM type_data