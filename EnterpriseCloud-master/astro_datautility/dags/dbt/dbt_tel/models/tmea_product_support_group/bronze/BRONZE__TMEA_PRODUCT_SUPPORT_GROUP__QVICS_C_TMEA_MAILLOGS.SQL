{{ config(
        materialized='tel_incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='QVICS_C_TMEA_MAILLOGS'
        ,unique_key = ['']
        ,tags=["qvics"]
        ,transient=false
        ) }}

    with source_data as
    (
    SELECT
	JSONFIELD:ID::Number(38,0) AS ID,
	JSONFIELD:Operator::String AS Operator,
	JSONFIELD:OperatorName::String AS OperatorName,
	JSONFIELD:TOAddress::String AS TOAddress,
	JSONFIELD:CCAddress::String AS CCAddress,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:SentAt,'/Date()/')) AS SentAt,
	JSONFIELD:Subject::String AS Subject,
	JSONFIELD:error::String AS error,
	JSONFIELD:isReminder::String AS isReminder,
	JSONFIELD:modelName::String AS modelName,
	JSONFIELD:modelKey::Number(38,0) AS modelKey,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'MailLogs') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'MailLogs') }})
    )
    ,transform_data as
    (
    SELECT
	'{{ invocation_id }}' AS _AUDIT_LOG_ID
,	 SHA2('hash_me') AS _ROW_HASH
,	_FILEDATE
,	_FILENAME
,	ID
,	Operator
,	OperatorName
,	TOAddress
,	CCAddress
,	SentAt
,	Subject
,	error
,	isReminder
,	modelName
,	modelKey
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID
,	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
,	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
,	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME
,	ID
,	Operator
,	OperatorName
,	TOAddress
,	CCAddress
,	SentAt
,	Subject
,	error
,	isReminder
,	modelName
,	modelKey
 from transform_data 
)
SELECT * from type_data