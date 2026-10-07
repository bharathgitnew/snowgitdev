{{ config(
        materialized='incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='Options'
        ,unique_key = ['']
		,tags=["qvics"]
        ,transient=false
    ) }}

    with source_data as
    (
    SELECT
	ID AS ID,
	USERID AS USERID,
	NAME AS NAME,
	VALUE AS VALUE,
	_FILEDATE,
	_FILENAME
FROM {{ ref('ODS__QVICS_C_TMEA__OPTIONS') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ ref('ODS__QVICS_C_TMEA__OPTIONS') }})
    )
    ,transform_data as
    (
    SELECT
	_FILEDATE,
	_FILENAME,
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	 SHA2('hash_me') AS _ROW_HASH,
	ID,
	USERID,
	NAME,
	VALUE
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	ID,
	USERID,
	NAME,
	VALUE
 from transform_data 
)
SELECT * from type_data