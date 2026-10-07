{{ config(
        materialized='incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='ApprovalActivities'
        ,unique_key = ['']
		,tags=["qvics"]
        ,transient=false
        ) }}

    with source_data as
    (
    SELECT
	JSONFIELD:ID::Number(38,0) AS ID,
	JSONFIELD:TroubleID::Number(38,0) AS TroubleID,
	JSONFIELD:Sequence::Number(38,0) AS Sequence,
	JSONFIELD:ApprovalName_J::String AS ApprovalName_J,
	JSONFIELD:ApprovalName_E::String AS ApprovalName_E,
	JSONFIELD:ApprovalCategory::Number(38,0) AS ApprovalCategory,
	JSONFIELD:Approver::String AS Approver,
	JSONFIELD:ApproverName::String AS ApproverName,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:ApprovedAt,'/Date()/')) AS ApprovedAt,
	JSONFIELD:LabelName_J::String AS LabelName_J,
	JSONFIELD:LabelName_E::String AS LabelName_E,
	JSONFIELD:IsCurrent::String AS IsCurrent,
	JSONFIELD:NextID::Number(38,0) AS NextID,
	JSONFIELD:IsSkippable::String AS IsSkippable,
	JSONFIELD:IsSkipped::String AS IsSkipped,
	JSONFIELD:VerifierID::Number(38,0) AS VerifierID,
	JSONFIELD:VerifyCategory_J::String AS VerifyCategory_J,
	JSONFIELD:VerifyCategory_E::String AS VerifyCategory_E,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'ApprovalActivities') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'ApprovalActivities') }})
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
,	Sequence
,	ApprovalName_J
,	ApprovalName_E
,	ApprovalCategory
,	Approver
,	ApproverName
,	ApprovedAt
,	LabelName_J
,	LabelName_E
,	IsCurrent
,	NextID
,	IsSkippable
,	IsSkipped
,	VerifierID
,	VerifyCategory_J
,	VerifyCategory_E
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
,	Sequence
,	ApprovalName_J
,	ApprovalName_E
,	ApprovalCategory
,	Approver
,	ApproverName
,	ApprovedAt
,	LabelName_J
,	LabelName_E
,	IsCurrent
,	NextID
,	IsSkippable
,	IsSkipped
,	VerifierID
,	VerifyCategory_J
,	VerifyCategory_E
 from transform_data 
)
SELECT * from type_data