/************
Model file generated from Python utility
*************/

{{ config(
	materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
	alias='TELCUSTOMER_USER_ROLE',
	transient=false
) }}

with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		JSONFIELD:"USERID"::NUMBER(38,10) AS USERID,
		JSONFIELD:"ROLE_ID"::NUMBER(38,10) AS ROLE_ID
	FROM {{ source("TELCUSTOMER_DIVERSESYSTEMS", "USER_ROLE") }}
WHERE
	_FILEDATE = (SELECT MAX(RUN_TIME) FROM {{ source('TELCUSTOMER_DIVERSESYSTEMS', 'CONTROLTABLE') }} WHERE TABLE_NAME = 'USER_ROLE' ) 
),

transform_data as (
	SELECT
		_FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		_UPLOADDATE AS _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		USERID,
		ROLE_ID
	FROM source_data
),

type_data as (
	SELECT
		CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME,
		_UPLOADDATE,
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		CAST(USERID AS NUMBER(38,10)) AS USERID,
		CAST(ROLE_ID AS NUMBER(38,10)) AS ROLE_ID
	FROM transform_data
)

SELECT * FROM type_data