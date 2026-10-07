/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='TELCUSTOMER_UGK_BENEFIT',
	transient=false
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"UGK_ID"::NUMBER(38,10) AS UGK_ID,
		JSONFIELD:"BENEFIT"::VARCHAR AS BENEFIT
	FROM {{ source("TELCUSTOMER_DIVERSESYSTEMS", "UGK_BENEFIT") }}
WHERE
	_FILEDATE = (SELECT MAX(RUN_TIME) FROM {{ source('TELCUSTOMER_DIVERSESYSTEMS', 'CONTROLTABLE') }} WHERE TABLE_NAME = 'UGK_BENEFIT' ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		UGK_ID,
		BENEFIT
	FROM source_data
),

type_data as (
	SELECT
		CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		CAST(UGK_ID AS NUMBER(38,10)) AS UGK_ID,
		BENEFIT
	FROM transform_data
)

SELECT * FROM type_data