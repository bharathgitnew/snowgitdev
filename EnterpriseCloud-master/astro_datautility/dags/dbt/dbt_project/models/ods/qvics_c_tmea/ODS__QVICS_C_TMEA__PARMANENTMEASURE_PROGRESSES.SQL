{{ config(
        materialized='incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='ParmanentMeasure_Progresses'
        ,unique_key = ['']
		,tags=["qvics"]
        ,transient=false
        ) }}

    with source_data as
    (
    SELECT
	JSONFIELD:ID::Number(38,0) AS ID,
	JSONFIELD:TroubleID::Number(38,0) AS TroubleID,
	JSONFIELD:ProgressID::Number(38,0) AS ProgressID,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:registeredAt,'/Date()/')) AS registeredAt,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:processDeadLine,'/Date()/')) AS processDeadLine,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:processedAt,'/Date()/')) AS processedAt,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:processDueDate,'/Date()/')) AS processDueDate,
	JSONFIELD:processedBy::String AS processedBy,
	JSONFIELD:processedByName::String AS processedByName,
	JSONFIELD:instructBy::String AS instructBy,
	JSONFIELD:instructByName::String AS instructByName,
	JSONFIELD:IsEnd::String AS IsEnd,
	JSONFIELD:JobNo::String AS JobNo,
	JSONFIELD:Notes::String AS Notes,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'ParmanentMeasure_Progresses') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'ParmanentMeasure_Progresses') }})
    )
    ,transform_data as
    (
    SELECT
	_FILEDATE
,	_FILENAME
,	'{{ invocation_id }}' AS _AUDIT_LOG_ID
,	 SHA2('hash_me') AS _ROW_HASH
,	ID
,	TroubleID
,	ProgressID
,	registeredAt
,	processDeadLine
,	processedAt
,	processDueDate
,	processedBy
,	processedByName
,	instructBy
,	instructByName
,	IsEnd
,	JobNo
,	Notes
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
,	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME
,	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID
,	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
,	ID
,	TroubleID
,	ProgressID
,	registeredAt
,	processDeadLine
,	processedAt
,	processDueDate
,	processedBy
,	processedByName
,	instructBy
,	instructByName
,	IsEnd
,	JobNo
,	Notes
 from transform_data 
)
SELECT * from type_data