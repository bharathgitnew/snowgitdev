{{ config(
        materialized='tel_incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='QVICS_EmergentMeasures'
        ,unique_key = ['']
		,tags=["qvics"]
        ,transient=false
        ) }}

    with source_data as
    (
    SELECT
	JSONFIELD:ID::Number(38,0) AS ID,
	JSONFIELD:TroubleID::Number(38,0) AS TroubleID,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:causeIdentificationDate,'/Date()/')) AS causeIdentificationDate,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:ExecutionDate,'/Date()/')) AS ExecutionDate,
	JSONFIELD:Measures::String AS Measures,
	JSONFIELD:Measures_Notag::String AS Measures_Notag,
	JSONFIELD:rootCause::String AS rootCause,
	JSONFIELD:rootCause_Notag::String AS rootCause_Notag,
	JSONFIELD:counterMeasure::String AS counterMeasure,
	JSONFIELD:counterMeasure_Notag::String AS counterMeasure_Notag,
	JSONFIELD:ClaimSurveyDemandID::Number(38,0) AS ClaimSurveyDemandID,
	JSONFIELD:InformationDevelopmentID::Number(38,0) AS InformationDevelopmentID,
	JSONFIELD:ClaimFromCustomer::String AS ClaimFromCustomer,
	JSONFIELD:ClaimFromCustomer_Notag::String AS ClaimFromCustomer_Notag,
	JSONFIELD:IsReportNecessity::String AS IsReportNecessity,
	JSONFIELD:IsNeedDesiredDeadline::String AS IsNeedDesiredDeadline,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:DesiredDeliveryDate,'/Date()/')) AS DesiredDeliveryDate,
	JSONFIELD:AnswerLanguage::String AS AnswerLanguage,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:CreatedAt,'/Date()/')) AS CreatedAt,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:UpdatedAt,'/Date()/')) AS UpdatedAt,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'EmergentMeasures') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'EmergentMeasures') }})
    )
    ,transform_data as
    (
    SELECT
	'{{ invocation_id }}' AS _AUDIT_LOG_ID
,	 SHA2('hash_me') AS _ROW_HASH
,	_FILEDATE
,	_FILENAME
,	ID
,	TroubleID
,	causeIdentificationDate
,	ExecutionDate
,	Measures
,	Measures_Notag
,	rootCause
,	rootCause_Notag
,	counterMeasure
,	counterMeasure_Notag
,	ClaimSurveyDemandID
,	InformationDevelopmentID
,	ClaimFromCustomer
,	ClaimFromCustomer_Notag
,	IsReportNecessity
,	IsNeedDesiredDeadline
,	DesiredDeliveryDate
,	AnswerLanguage
,	CreatedAt
,	UpdatedAt
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID
,	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
,	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
,	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME
,	ID
,	TroubleID
,	causeIdentificationDate
,	ExecutionDate
,	Measures
,	Measures_Notag
,	rootCause
,	rootCause_Notag
,	counterMeasure
,	counterMeasure_Notag
,	ClaimSurveyDemandID
,	InformationDevelopmentID
,	ClaimFromCustomer
,	ClaimFromCustomer_Notag
,	IsReportNecessity
,	IsNeedDesiredDeadline
,	DesiredDeliveryDate
,	AnswerLanguage
,	CreatedAt
,	UpdatedAt
 from transform_data 
)
SELECT * from type_data