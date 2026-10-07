{{ config(
        materialized='tel_incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='QVICS_C_TMEA_TROUBLES'
        ,unique_key = ['']
		,tags=["qvics"]
        ,transient=false
        ) }}

    with source_data as
    (
    SELECT
	JSONFIELD:ID::Number(38,0) AS ID,
	JSONFIELD:QVICSID::Number(38,0) AS QVICSID,
	JSONFIELD:Subject::String AS Subject,
	JSONFIELD:Reporter::String AS Reporter,
	JSONFIELD:ReporterName::String AS ReporterName,
	JSONFIELD:WTSCOwner::String AS WTSCOwner,
	JSONFIELD:WTSCOwnerName::String AS WTSCOwnerName,
	JSONFIELD:Phenomena::String AS Phenomena,
	JSONFIELD:Phenomena_Notag::String AS Phenomena_Notag,
	JSONFIELD:RemarksColumn::String AS RemarksColumn,
	JSONFIELD:RemarksColumn_Notag::String AS RemarksColumn_Notag,
	JSONFIELD:StatusID::Number(38,0) AS StatusID,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:OccurenceDate,'/Date()/')) AS OccurenceDate,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:CompletionDate,'/Date()/')) AS CompletionDate,
	JSONFIELD:CallID::String AS CallID,
	JSONFIELD:InquiryID::String AS InquiryID,
	JSONFIELD:BusinessUnitID::Number(38,0) AS BusinessUnitID,
	JSONFIELD:IsEscalationTrouble::String AS IsEscalationTrouble,
	JSONFIELD:EscalationTypeID::Number(38,0) AS EscalationTypeID,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:PreEscalationInputedAt,'/Date()/')) AS PreEscalationInputedAt,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:EscalationInputedAt,'/Date()/')) AS EscalationInputedAt,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:PostEscalationInputedAt,'/Date()/')) AS PostEscalationInputedAt,
	JSONFIELD:FERequestTypeID::Number(38,0) AS FERequestTypeID,
	JSONFIELD:PriorityReason::String AS PriorityReason,
	JSONFIELD:IsCompleteTopPriority::String AS IsCompleteTopPriority,
	JSONFIELD:IsTopReport::String AS IsTopReport,
	JSONFIELD:IsImportantClaim::String AS IsImportantClaim,
	JSONFIELD:CatsCallNo::String AS CatsCallNo,
	JSONFIELD:TSRReportNo::String AS TSRReportNo,
	JSONFIELD:SafetyVICSNo::String AS SafetyVICSNo,
	JSONFIELD:IsSafetyVicsTrouble::String AS IsSafetyVicsTrouble,
	JSONFIELD:IsRelatedWithSafetyVICS::String AS IsRelatedWithSafetyVICS,
	JSONFIELD:SafetyTIRSNo::String AS SafetyTIRSNo,
	JSONFIELD:MachineOperationalStatusID::Number(38,0) AS MachineOperationalStatusID,
	JSONFIELD:AlermCode::String AS AlermCode,
	JSONFIELD:LogId::Number(38,0) AS LogId,
	JSONFIELD:LogStorageLocation::String AS LogStorageLocation,
	JSONFIELD:DemandFromCustomerID::Number(38,0) AS DemandFromCustomerID,
	JSONFIELD:JobNo::String AS JobNo,
	JSONFIELD:SpreadConditionID::Number(38,0) AS SpreadConditionID,
	JSONFIELD:IsPropulsionIssue::String AS IsPropulsionIssue,
	JSONFIELD:PropulsionIssueRankID::Number(38,0) AS PropulsionIssueRankID,
	JSONFIELD:CustomerSectionName::String AS CustomerSectionName,
	JSONFIELD:CustomerChargeName::String AS CustomerChargeName,
	JSONFIELD:CustomerContactAddress::String AS CustomerContactAddress,
	JSONFIELD:WaferPieces::String AS WaferPieces,
	JSONFIELD:WaferInch::String AS WaferInch,
	JSONFIELD:WaferLot::String AS WaferLot,
	JSONFIELD:RelatedQVICSIDList::String AS RelatedQVICSIDList,
	JSONFIELD:bugOccurrenceVer::String AS bugOccurrenceVer,
	JSONFIELD:IsCustomerClaimIssuedNo::String AS IsCustomerClaimIssuedNo,
	JSONFIELD:CustomerClaimIssuedNo::String AS CustomerClaimIssuedNo,
	JSONFIELD:plateLength::String AS plateLength,
	JSONFIELD:plateBreadth::String AS plateBreadth,
	JSONFIELD:platePiece::String AS platePiece,
	JSONFIELD:operatedTicketNo::String AS operatedTicketNo,
	JSONFIELD:operatedTicketNo1::String AS operatedTicketNo1,
	JSONFIELD:operatedTicketNo2::String AS operatedTicketNo2,
	JSONFIELD:operatedTicketNo3::String AS operatedTicketNo3,
	JSONFIELD:releaseInfo::String AS releaseInfo,
	JSONFIELD:releaseInfo_Notag::String AS releaseInfo_Notag,
	JSONFIELD:releaseVersion::String AS releaseVersion,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:releaseDate,'/Date()/')) AS releaseDate,
	JSONFIELD:M_softWareStatusesID::Number(38,0) AS M_softWareStatusesID,
	JSONFIELD:M_softWareClassificationsID::Number(38,0) AS M_softWareClassificationsID,
	JSONFIELD:RedMineIssueNo::Number(38,0) AS RedMineIssueNo,
	JSONFIELD:priorityID::Number(38,0) AS priorityID,
	JSONFIELD:isProcessingInfluence::String AS isProcessingInfluence,
	JSONFIELD:M_OperationBeforeTroubleID::Number(38,0) AS M_OperationBeforeTroubleID,
	JSONFIELD:M_StatusOfTroubleMomentID::Number(38,0) AS M_StatusOfTroubleMomentID,
	JSONFIELD:CRMIssueNo::String AS CRMIssueNo,
	JSONFIELD:UID::String AS UID,
	JSONFIELD:isRelatedWithCRM::String AS isRelatedWithCRM,
	JSONFIELD:issuanceMotiveID::Number(38,0) AS issuanceMotiveID,
	JSONFIELD:LocalCorporationID::Number(38,0) AS LocalCorporationID,
	JSONFIELD:STSFID::Number(38,0) AS STSFID,
	JSONFIELD:STSFInputContents::String AS STSFInputContents,
	JSONFIELD:STSFInputContents_Notag::String AS STSFInputContents_Notag,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:CreatedAt,'/Date()/')) AS CreatedAt,
	JSONFIELD:CreatedBy::String AS CreatedBy,
	JSONFIELD:CreatedByName::String AS CreatedByName,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:UpdatedAt,'/Date()/')) AS UpdatedAt,
	JSONFIELD:UpdatedBy::String AS UpdatedBy,
	JSONFIELD:UpdatedByName::String AS UpdatedByName,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:DeletedAt,'/Date()/')) AS DeletedAt,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'Troubles') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'Troubles') }})
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
,	Subject
,	Reporter
,	ReporterName
,	WTSCOwner
,	WTSCOwnerName
,	Phenomena
,	Phenomena_Notag
,	RemarksColumn
,	RemarksColumn_Notag
,	StatusID
,	OccurenceDate
,	CompletionDate
,	CallID
,	InquiryID
,	BusinessUnitID
,	IsEscalationTrouble
,	EscalationTypeID
,	PreEscalationInputedAt
,	EscalationInputedAt
,	PostEscalationInputedAt
,	FERequestTypeID
,	PriorityReason
,	IsCompleteTopPriority
,	IsTopReport
,	IsImportantClaim
,	CatsCallNo
,	TSRReportNo
,	SafetyVICSNo
,	IsSafetyVicsTrouble
,	IsRelatedWithSafetyVICS
,	SafetyTIRSNo
,	MachineOperationalStatusID
,	AlermCode
,	LogId
,	LogStorageLocation
,	DemandFromCustomerID
,	JobNo
,	SpreadConditionID
,	IsPropulsionIssue
,	PropulsionIssueRankID
,	CustomerSectionName
,	CustomerChargeName
,	CustomerContactAddress
,	WaferPieces
,	WaferInch
,	WaferLot
,	RelatedQVICSIDList
,	bugOccurrenceVer
,	IsCustomerClaimIssuedNo
,	CustomerClaimIssuedNo
,	plateLength
,	plateBreadth
,	platePiece
,	operatedTicketNo
,	operatedTicketNo1
,	operatedTicketNo2
,	operatedTicketNo3
,	releaseInfo
,	releaseInfo_Notag
,	releaseVersion
,	releaseDate
,	M_softWareStatusesID
,	M_softWareClassificationsID
,	RedMineIssueNo
,	priorityID
,	isProcessingInfluence
,	M_OperationBeforeTroubleID
,	M_StatusOfTroubleMomentID
,	CRMIssueNo
,	UID
,	isRelatedWithCRM
,	issuanceMotiveID
,	LocalCorporationID
,	STSFID
,	STSFInputContents
,	STSFInputContents_Notag
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
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID
,	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
,	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
,	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME
,	ID
,	QVICSID
,	Subject
,	Reporter
,	ReporterName
,	WTSCOwner
,	WTSCOwnerName
,	Phenomena
,	Phenomena_Notag
,	RemarksColumn
,	RemarksColumn_Notag
,	StatusID
,	OccurenceDate
,	CompletionDate
,	CallID
,	InquiryID
,	BusinessUnitID
,	IsEscalationTrouble
,	EscalationTypeID
,	PreEscalationInputedAt
,	EscalationInputedAt
,	PostEscalationInputedAt
,	FERequestTypeID
,	PriorityReason
,	IsCompleteTopPriority
,	IsTopReport
,	IsImportantClaim
,	CatsCallNo
,	TSRReportNo
,	SafetyVICSNo
,	IsSafetyVicsTrouble
,	IsRelatedWithSafetyVICS
,	SafetyTIRSNo
,	MachineOperationalStatusID
,	AlermCode
,	LogId
,	LogStorageLocation
,	DemandFromCustomerID
,	JobNo
,	SpreadConditionID
,	IsPropulsionIssue
,	PropulsionIssueRankID
,	CustomerSectionName
,	CustomerChargeName
,	CustomerContactAddress
,	WaferPieces
,	WaferInch
,	WaferLot
,	RelatedQVICSIDList
,	bugOccurrenceVer
,	IsCustomerClaimIssuedNo
,	CustomerClaimIssuedNo
,	plateLength
,	plateBreadth
,	platePiece
,	operatedTicketNo
,	operatedTicketNo1
,	operatedTicketNo2
,	operatedTicketNo3
,	releaseInfo
,	releaseInfo_Notag
,	releaseVersion
,	releaseDate
,	M_softWareStatusesID
,	M_softWareClassificationsID
,	RedMineIssueNo
,	priorityID
,	isProcessingInfluence
,	M_OperationBeforeTroubleID
,	M_StatusOfTroubleMomentID
,	CRMIssueNo
,	UID
,	isRelatedWithCRM
,	issuanceMotiveID
,	LocalCorporationID
,	STSFID
,	STSFInputContents
,	STSFInputContents_Notag
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