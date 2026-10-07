{{ config(
        materialized='incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='QVICS'
        ,unique_key = ['']
        ,tags=["qvics"]
        ,transient=false
        ) }}

    with source_data as
    (
    SELECT
	JSONFIELD:ID::Number(38,0) AS ID,
	JSONFIELD:UsefulPoint::Number(38,0) AS UsefulPoint,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:CreatedAt,'/Date()/')) AS CreatedAt,
	JSONFIELD:CreatedBy::String AS CreatedBy,
	JSONFIELD:CreatedByName::String AS CreatedByName,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:UpdatedAt,'/Date()/')) AS UpdatedAt,
	JSONFIELD:UpdatedBy::String AS UpdatedBy,
	JSONFIELD:UpdatedByName::String AS UpdatedByName,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:DeletedAt,'/Date()/')) AS DeletedAt,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'QVICS') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'QVICS') }})
    )
    ,transform_data as
    (
    SELECT
	_FILEDATE
,	_FILENAME
,	'{{ invocation_id }}' AS _AUDIT_LOG_ID
,	 SHA2('hash_me') AS _ROW_HASH
,	ID
,	UsefulPoint
,	CreatedAt
,	CreatedBy
,	CreatedByName
,	UpdatedAt
,	UpdatedBy
,	UpdatedByName
,	DeletedAt
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
,	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME
,	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID
,	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
,	ID
,	UsefulPoint
,	CreatedAt
,	CreatedBy
,	CreatedByName
,	UpdatedAt
,	UpdatedBy
,	UpdatedByName
,	DeletedAt
 from transform_data 
)
SELECT * from type_data