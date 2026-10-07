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
	JSONFIELD:ID::Number(38,0) AS ID,
	JSONFIELD:UserID::String AS UserID,
	JSONFIELD:Name::String AS Name,
	JSONFIELD:Value::String AS Value,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'Options') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'Options') }})
    )
    ,transform_data as
    (
    SELECT
	_FILEDATE
,	_FILENAME
,	'{{ invocation_id }}' AS _AUDIT_LOG_ID
,	 SHA2('hash_me') AS _ROW_HASH
,	ID
,	UserID
,	Name
,	Value
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
,	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME
,	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID
,	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
,	ID
,	UserID
,	Name
,	Value
 from transform_data 
)
SELECT * from type_data