{{ config(
        materialized='incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='Message_Addresses'
        ,unique_key = ['']
        ,tags=["qvics"]
        ,transient=false
        ) }}

    with source_data as
    (
    SELECT
	JSONFIELD:id::Number(38,0) AS id,
	JSONFIELD:messageID::Number(38,0) AS messageID,
	JSONFIELD:addressCategory::Number(38,0) AS addressCategory,
	JSONFIELD:address::String AS address,
	JSONFIELD:addressName::String AS addressName,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'Message_Addresses') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'Message_Addresses') }})
    )
    ,transform_data as
    (
    SELECT
	_FILEDATE
,	_FILENAME
,	'{{ invocation_id }}' AS _AUDIT_LOG_ID
,	 SHA2('hash_me') AS _ROW_HASH
,	id
,	messageID
,	addressCategory
,	address
,	addressName
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
,	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME
,	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID
,	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
,	id
,	messageID
,	addressCategory
,	address
,	addressName
 from transform_data 
)
SELECT * from type_data