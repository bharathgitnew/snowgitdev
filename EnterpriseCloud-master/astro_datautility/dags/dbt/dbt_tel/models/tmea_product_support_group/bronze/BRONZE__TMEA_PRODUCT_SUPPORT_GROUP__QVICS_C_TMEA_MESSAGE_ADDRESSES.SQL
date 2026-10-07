{{ config(
        materialized='tel_incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='QVICS_C_TMEA_MESSAGE_ADDRESSES'
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
	'{{ invocation_id }}' AS _AUDIT_LOG_ID
,	 SHA2('hash_me') AS _ROW_HASH
,	_FILEDATE
,	_FILENAME
,	id
,	messageID
,	addressCategory
,	address
,	addressName
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID
,	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
,	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
,	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME
,	id
,	messageID
,	addressCategory
,	address
,	addressName
 from transform_data 
)
SELECT * from type_data