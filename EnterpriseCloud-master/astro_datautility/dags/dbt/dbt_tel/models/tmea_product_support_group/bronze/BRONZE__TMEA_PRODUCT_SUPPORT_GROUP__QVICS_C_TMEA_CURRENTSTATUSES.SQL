{{ config(
        materialized='tel_incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='QVICS_C_TMEA_CURRENTSTATUSES'
        ,unique_key = ['']
		,tags=["qvics"]
        ,transient=false
        ) }}

    with source_data as
    (
    SELECT
	JSONFIELD:ID::Number(38,0) AS ID,
	JSONFIELD:QVICSID::Number(38,0) AS QVICSID,
	JSONFIELD:CategoryID::Number(38,0) AS CategoryID,
	JSONFIELD:Comment::String AS Comment,
	JSONFIELD:Comment_Notag::String AS Comment_Notag,
	JSONFIELD:CreatedBy::String AS CreatedBy,
	JSONFIELD:CreatedByName::String AS CreatedByName,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:CreatedAt,'/Date()/')) AS CreatedAt,
	JSONFIELD:UpdatedBy::String AS UpdatedBy,
	JSONFIELD:UpdatedByName::String AS UpdatedByName,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:UpdatedAt,'/Date()/')) AS UpdatedAt,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:DeletedAt,'/Date()/')) AS DeletedAt,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'CurrentStatuses') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'CurrentStatuses') }})
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
,	CategoryID
,	Comment
,	Comment_Notag
,	CreatedBy
,	CreatedByName
,	CreatedAt
,	UpdatedBy
,	UpdatedByName
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
,	CategoryID
,	Comment
,	Comment_Notag
,	CreatedBy
,	CreatedByName
,	CreatedAt
,	UpdatedBy
,	UpdatedByName
,	UpdatedAt
,	DeletedAt
 from transform_data 
)
SELECT * from type_data