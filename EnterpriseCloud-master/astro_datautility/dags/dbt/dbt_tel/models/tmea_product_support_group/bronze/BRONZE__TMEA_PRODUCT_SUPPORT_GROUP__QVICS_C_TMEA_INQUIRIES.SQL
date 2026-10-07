{{ config(
        materialized='tel_incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='QVICS_C_TMEA_INQUIRIES'
        ,unique_key = ['']
		,tags=["qvics"]
        ,transient=false
        ) }}

    with source_data as
    (
    SELECT
	JSONFIELD:ID::Number(38,0) AS ID,
	JSONFIELD:QVICSID::Number(38,0) AS QVICSID,
	JSONFIELD:Reporter::String AS Reporter,
	JSONFIELD:ReporterName::String AS ReporterName,
	JSONFIELD:Subject::String AS Subject,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:InquiryDate,'/Date()/')) AS InquiryDate,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:CompletionDate,'/Date()/')) AS CompletionDate,
	JSONFIELD:LocalCorporationID::Number(38,0) AS LocalCorporationID,
	JSONFIELD:StatusID::Number(38,0) AS StatusID,
	JSONFIELD:ClassificationID::Number(38,0) AS ClassificationID,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:CreatedAt,'/Date()/')) AS CreatedAt,
	JSONFIELD:CreatedBy::String AS CreatedBy,
	JSONFIELD:CreatedByName::String AS CreatedByName,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:UpdatedAt,'/Date()/')) AS UpdatedAt,
	JSONFIELD:UpdatedBy::String AS UpdatedBy,
	JSONFIELD:UpdatedByName::String AS UpdatedByName,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:DeletedAt,'/Date()/')) AS DeletedAt,
	JSONFIELD:MachineLogStatusID::Number(38,0) AS MachineLogStatusID,
	JSONFIELD:LogStorageLocation::String AS LogStorageLocation,
	JSONFIELD:priorityID::Number(38,0) AS priorityID,
	JSONFIELD:RelatedQVICSIDList::String AS RelatedQVICSIDList,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'Inquiries') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'Inquiries') }})
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
,	Reporter
,	ReporterName
,	Subject
,	InquiryDate
,	CompletionDate
,	LocalCorporationID
,	StatusID
,	ClassificationID
,	CreatedAt
,	CreatedBy
,	CreatedByName
,	UpdatedAt
,	UpdatedBy
,	UpdatedByName
,	DeletedAt
,	MachineLogStatusID
,	LogStorageLocation
,	priorityID
,	RelatedQVICSIDList
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
,	Reporter
,	ReporterName
,	Subject
,	InquiryDate
,	CompletionDate
,	LocalCorporationID
,	StatusID
,	ClassificationID
,	CreatedAt
,	CreatedBy
,	CreatedByName
,	UpdatedAt
,	UpdatedBy
,	UpdatedByName
,	DeletedAt
,	MachineLogStatusID
,	LogStorageLocation
,	priorityID
,	RelatedQVICSIDList
 from transform_data 
)
SELECT * from type_data