{{ config(
        materialized='incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='Parts'
        ,unique_key = ['']
		,tags=["qvics"]
        ,transient=false
        ) }}

    with source_data as
    (
    SELECT
	JSONFIELD:ID::Number(38,0) AS ID,
	JSONFIELD:QVICSID::Number(38,0) AS QVICSID,
	JSONFIELD:PartCategory::Number(38,0) AS PartCategory,
	JSONFIELD:NCDRRequiredStatusID::Number(38,0) AS NCDRRequiredStatusID,
	JSONFIELD:NCDRNumber::String AS NCDRNumber,
	JSONFIELD:PartNumber::String AS PartNumber,
	JSONFIELD:PartName::String AS PartName,
	JSONFIELD:PartType::String AS PartType,
	JSONFIELD:PartSN::String AS PartSN,
	JSONFIELD:PartSubCategoryID::Number(38,0) AS PartSubCategoryID,
	JSONFIELD:Quantity::String AS Quantity,
	JSONFIELD:Manufacturer::String AS Manufacturer,
	JSONFIELD:Supplier::String AS Supplier,
	JSONFIELD:Country::String AS Country,
	JSONFIELD:SONo::String AS SONo,
	JSONFIELD:isReturnTarget::String AS isReturnTarget,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:returnTargetCheckedAt,'/Date()/')) AS returnTargetCheckedAt,
	JSONFIELD:IsRentalProduct::String AS IsRentalProduct,
	JSONFIELD:Notes::String AS Notes,
	JSONFIELD:Price::Number(38,10) AS Price,
	JSONFIELD:IsCuPollutionProduct::String AS IsCuPollutionProduct,
	JSONFIELD:exchangeID::Number(38,0) AS exchangeID,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'Parts') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'Parts') }})
    )
    ,transform_data as
    (
    SELECT
	_FILEDATE
,	_FILENAME
,	'{{ invocation_id }}' AS _AUDIT_LOG_ID
,	 SHA2('hash_me') AS _ROW_HASH
,	ID
,	QVICSID
,	PartCategory
,	NCDRRequiredStatusID
,	NCDRNumber
,	PartNumber
,	PartName
,	PartType
,	PartSN
,	PartSubCategoryID
,	Quantity
,	Manufacturer
,	Supplier
,	Country
,	SONo
,	isReturnTarget
,	returnTargetCheckedAt
,	IsRentalProduct
,	Notes
,	Price
,	IsCuPollutionProduct
,	exchangeID
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
,	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME
,	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID
,	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
,	ID
,	QVICSID
,	PartCategory
,	NCDRRequiredStatusID
,	NCDRNumber
,	PartNumber
,	PartName
,	PartType
,	PartSN
,	PartSubCategoryID
,	Quantity
,	Manufacturer
,	Supplier
,	Country
,	SONo
,	isReturnTarget
,	returnTargetCheckedAt
,	IsRentalProduct
,	Notes
,	Price
,	IsCuPollutionProduct
,	exchangeID
 from transform_data 
)
SELECT * from type_data