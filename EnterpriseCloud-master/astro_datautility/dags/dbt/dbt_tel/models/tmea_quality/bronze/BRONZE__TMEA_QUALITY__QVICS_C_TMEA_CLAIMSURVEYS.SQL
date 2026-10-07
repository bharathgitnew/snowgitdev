{{ config(
        materialized='tel_incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='QVICS_C_TMEA_CLAIMSURVEYS'
        ,unique_key = ['']
        ,tags=["qvics"]
        ,transient=false
        ) }}

    with source_data as
    (
    SELECT
	JSONFIELD:ID::Number(38,0) AS ID,
	JSONFIELD:TroubleID::Number(38,0) AS TroubleID,
	JSONFIELD:ManageNo::String AS ManageNo,
	JSONFIELD:IsImportantClaim::String AS IsImportantClaim,
	JSONFIELD:JudgeID::Number(38,0) AS JudgeID,
	JSONFIELD:Judge::String AS Judge,
	JSONFIELD:JudgeName::String AS JudgeName,
	JSONFIELD:JudgmentReason::String AS JudgmentReason,
	JSONFIELD:JudgmentReason_Notag::String AS JudgmentReason_Notag,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:JudgedAt,'/Date()/')) AS JudgedAt,
	JSONFIELD:M_ClaimSurveyFactorID::Number(38,0) AS M_ClaimSurveyFactorID,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'ClaimSurveys') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'ClaimSurveys') }})
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
,	ManageNo
,	IsImportantClaim
,	JudgeID
,	Judge
,	JudgeName
,	JudgmentReason
,	JudgmentReason_Notag
,	JudgedAt
,	M_ClaimSurveyFactorID
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
,	ManageNo
,	IsImportantClaim
,	JudgeID
,	Judge
,	JudgeName
,	JudgmentReason
,	JudgmentReason_Notag
,	JudgedAt
,	M_ClaimSurveyFactorID
 from transform_data 
)
SELECT * from type_data