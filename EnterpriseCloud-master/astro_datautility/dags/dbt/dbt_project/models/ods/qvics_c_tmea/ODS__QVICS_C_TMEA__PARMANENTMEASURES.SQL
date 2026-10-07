{{ config(
        materialized='incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='ParmanentMeasures'
        ,unique_key = ['']
		,tags=["qvics"]
        ,transient=false
        ) }}

    with source_data as
    (
    SELECT
	JSONFIELD:ID::Number(38,0) AS ID,
	JSONFIELD:TroubleID::Number(38,0) AS TroubleID,
	JSONFIELD:Subject::String AS Subject,
	JSONFIELD:Measures_J::String AS Measures_J,
	JSONFIELD:Measures_J_Notag::String AS Measures_J_Notag,
	JSONFIELD:Measures_E::String AS Measures_E,
	JSONFIELD:Measures_E_Notag::String AS Measures_E_Notag,
	JSONFIELD:Cause_J::String AS Cause_J,
	JSONFIELD:Cause_J_Notag::String AS Cause_J_Notag,
	JSONFIELD:Cause_E::String AS Cause_E,
	JSONFIELD:Cause_E_Notag::String AS Cause_E_Notag,
	JSONFIELD:Spread_J::String AS Spread_J,
	JSONFIELD:Spread_J_Notag::String AS Spread_J_Notag,
	JSONFIELD:Spread_E::String AS Spread_E,
	JSONFIELD:Spread_E_Notag::String AS Spread_E_Notag,
	JSONFIELD:IsDesignChanged::String AS IsDesignChanged,
	JSONFIELD:ECENo::String AS ECENo,
	JSONFIELD:JobNo::String AS JobNo,
	JSONFIELD:ECANo::String AS ECANo,
	JSONFIELD:FCNNo::String AS FCNNo,
	JSONFIELD:Comments::String AS Comments,
	JSONFIELD:Comments_Notag::String AS Comments_Notag,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:CreatedAt,'/Date()/')) AS CreatedAt,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:UpdatedAt,'/Date()/')) AS UpdatedAt,
	JSONFIELD:IsECAIssued::String AS IsECAIssued,
	JSONFIELD:ECPNo::String AS ECPNo,
	JSONFIELD:operatedTicketNo::String AS operatedTicketNo,
	JSONFIELD:operatedTicketNo1::String AS operatedTicketNo1,
	JSONFIELD:operatedTicketNo2::String AS operatedTicketNo2,
	JSONFIELD:operatedTicketNo3::String AS operatedTicketNo3,
	JSONFIELD:releaseInfo::String AS releaseInfo,
	JSONFIELD:releaseInfo_Notag::String AS releaseInfo_Notag,
	JSONFIELD:releaseVersion::String AS releaseVersion,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:releaseDate,'/Date()/')) AS releaseDate,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'ParmanentMeasures') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'ParmanentMeasures') }})
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
,	Subject
,	Measures_J
,	Measures_J_Notag
,	Measures_E
,	Measures_E_Notag
,	Cause_J
,	Cause_J_Notag
,	Cause_E
,	Cause_E_Notag
,	Spread_J
,	Spread_J_Notag
,	Spread_E
,	Spread_E_Notag
,	IsDesignChanged
,	ECENo
,	JobNo
,	ECANo
,	FCNNo
,	Comments
,	Comments_Notag
,	CreatedAt
,	UpdatedAt
,	IsECAIssued
,	ECPNo
,	operatedTicketNo
,	operatedTicketNo1
,	operatedTicketNo2
,	operatedTicketNo3
,	releaseInfo
,	releaseInfo_Notag
,	releaseVersion
,	releaseDate
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
,	Subject
,	Measures_J
,	Measures_J_Notag
,	Measures_E
,	Measures_E_Notag
,	Cause_J
,	Cause_J_Notag
,	Cause_E
,	Cause_E_Notag
,	Spread_J
,	Spread_J_Notag
,	Spread_E
,	Spread_E_Notag
,	IsDesignChanged
,	ECENo
,	JobNo
,	ECANo
,	FCNNo
,	Comments
,	Comments_Notag
,	CreatedAt
,	UpdatedAt
,	IsECAIssued
,	ECPNo
,	operatedTicketNo
,	operatedTicketNo1
,	operatedTicketNo2
,	operatedTicketNo3
,	releaseInfo
,	releaseInfo_Notag
,	releaseVersion
,	releaseDate
 from transform_data 
)
SELECT * from type_data