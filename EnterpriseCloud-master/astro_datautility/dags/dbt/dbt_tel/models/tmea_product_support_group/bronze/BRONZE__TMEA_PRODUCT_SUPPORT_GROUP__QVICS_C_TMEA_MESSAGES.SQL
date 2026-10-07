{{ config(
        materialized='tel_incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='QVICS_C_TMEA_MESSAGES'
        ,unique_key = ['']
		,tags=["qvics"]
        ,transient=false
        ) }}

    with source_data as
    (
    SELECT
	JSONFIELD:ID::Number(38,0) AS ID,
	JSONFIELD:QVICSID::Number(38,0) AS QVICSID,
	JSONFIELD:ParentID::Number(38,0) AS ParentID,
	JSONFIELD:ReplyLevel::Number(38,0) AS ReplyLevel,
	JSONFIELD:Author::String AS Author,
	JSONFIELD:AuthorName::String AS AuthorName,
	JSONFIELD:Subject::String AS Subject,
	JSONFIELD:Message::String AS Message,
	JSONFIELD:Message_Notag::String AS Message_Notag,
	JSONFIELD:MessageCategory::Number(38,0) AS MessageCategory,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:ReplyDate,'/Date()/')) AS ReplyDate,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:CreatedAt,'/Date()/')) AS CreatedAt,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:UpdatedAt,'/Date()/')) AS UpdatedAt,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:DeletedAt,'/Date()/')) AS DeletedAt,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'Messages') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'Messages') }})
    )
    ,transform_data as
    (
    SELECT
	'{{ invocation_id }}' AS _AUDIT_LOG_ID
,	 SHA2('hash_me') AS _ROW_HASH
,	_FILEDATE
,	_FILENAME
,	ID
,	QVICSID
,	ParentID
,	ReplyLevel
,	Author
,	AuthorName
,	Subject
,	Message
,	Message_Notag
,	MessageCategory
,	ReplyDate
,	CreatedAt
,	UpdatedAt
,	DeletedAt
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID
,	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
,	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
,	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME
,	ID
,	QVICSID
,	ParentID
,	ReplyLevel
,	Author
,	AuthorName
,	Subject
,	Message
,	Message_Notag
,	MessageCategory
,	ReplyDate
,	CreatedAt
,	UpdatedAt
,	DeletedAt
 from transform_data 
)
SELECT * from type_data