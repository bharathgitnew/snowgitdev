{{ config(
        materialized='tel_incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='QVICS_C_TMEA_PART_CONTROLS'
        ,unique_key = ['']
		,tags=["qvics"]
        ,transient=false
        ) }}

    with source_data as
    (
    SELECT
	JSONFIELD:ID::Number(38,0) AS ID,
	JSONFIELD:PartID::Number(38,0) AS PartID,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:registeredAt,'/Date()/')) AS registeredAt,
	JSONFIELD:sendingChargePerson::String AS sendingChargePerson,
	JSONFIELD:sendingChargePersonName::String AS sendingChargePersonName,
	JSONFIELD:shippingChargePerson::String AS shippingChargePerson,
	JSONFIELD:shippingChargePersonName::String AS shippingChargePersonName,
	JSONFIELD:shippingAddress::String AS shippingAddress,
	JSONFIELD:shippingMethod::String AS shippingMethod,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:shippingScheduleDate,'/Date()/')) AS shippingScheduleDate,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:ArrivalDate,'/Date()/')) AS ArrivalDate,
	JSONFIELD:Notes::String AS Notes,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:CreatedAt,'/Date()/')) AS CreatedAt,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:UpdatedAt,'/Date()/')) AS UpdatedAt,
	JSONFIELD:PartDisposal::String AS PartDisposal,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:DisposalDate,'/Date()/')) AS DisposalDate,
	JSONFIELD:PartArchiveDepartment::String AS PartArchiveDepartment,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'Part_Controls') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'Part_Controls') }})
    )
    ,transform_data as
    (
    SELECT
	_FILEDATE
,	_FILENAME
,	'{{ invocation_id }}' AS _AUDIT_LOG_ID
,	 SHA2('hash_me') AS _ROW_HASH
,	ID
,	PartID
,	registeredAt
,	sendingChargePerson
,	sendingChargePersonName
,	shippingChargePerson
,	shippingChargePersonName
,	shippingAddress
,	shippingMethod
,	shippingScheduleDate
,	ArrivalDate
,	Notes
,	CreatedAt
,	UpdatedAt
,	PartDisposal
,	DisposalDate
,	PartArchiveDepartment
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
,	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME
,	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID
,	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
,	ID
,	PartID
,	registeredAt
,	sendingChargePerson
,	sendingChargePersonName
,	shippingChargePerson
,	shippingChargePersonName
,	shippingAddress
,	shippingMethod
,	shippingScheduleDate
,	ArrivalDate
,	Notes
,	CreatedAt
,	UpdatedAt
,	PartDisposal
,	DisposalDate
,	PartArchiveDepartment
 from transform_data 
)
SELECT * from type_data