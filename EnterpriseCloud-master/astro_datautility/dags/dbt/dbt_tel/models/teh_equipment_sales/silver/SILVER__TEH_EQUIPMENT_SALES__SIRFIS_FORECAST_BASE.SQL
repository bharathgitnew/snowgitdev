--Business logic changed for SET_START_DATE value 5.6.2022
{{ config(
       materialized='tel_incremental'  ,
    incremental_strategy='insert_overwrite'  ,
    alias='sirfis_forecast_base'  
) }}

with source_data as
(
	SELECT
		 _FileDate
		,ForecastId
		,UEID
		,SupplierCSIChildCount
		,ChildCSIGaps
		,StateCode
		,StatusCode
		,Category
		,Model
		,CEID
		,EntityCode
		,CapacityProcess
		,Site
		,Description
		,SupplierNumber
		,SupplierName
		,TransitMode
		,TransitOrigin
		,TransitTime
		,ParentForecastId
		,RDD
		,CTD
		,RTD
		,ResponseSTD
		,STD
		,SupplierMap
		,ReuseCapacityProcess
		,ReuseEntityCode
		,ReuseCEID
		,ReuseSite
		,Hand
		,Impact
		,ReleaseDate
		,ResponseDate
		,PONumber
		,POLineNumber
		,Quantity
		,BuildTime
		,ConversionLocation
		,Action
		,SerialNumber
		,ActionDate
		,Campus
		,CPID
		,CreatedDate
		,CSIFulfillment
		,CSIType
		,Draft
		,IsCSILine
		,MaxCSIGap
		,MaxCSISTD
		,MinCSIRTD
		,ModifiedDate
		,PID
		,PODeliveryDate
		,POReleaseIndicator
		,PreviousSDD
		,ReleaseUserId
		,ReleaseUserName
		,ResponseComment
		,ResponseGapReason
		,ResponsePullInProbability
		,ResponseSTDConditional
		,ResponseNextUpdate
		,ResponseSupplierConversionRDD
		,ResponseUserId
		,ResponseUserName
		,SDD
		,STDConditional
		,StorageLocation
		,SupplierComment
		,SupplierConversionRDD
		,PrefacStart
		,SetStart
		,ConvertStart
		,_AppendedDate
		,Revision_Desc_Order
	FROM {{ ref('BRONZE__TEH_EQUIPMENT_SALES__SIRFIS_SIRFIS_FORECAST_BASE') }}
)

, Business_Unit_Lookup_Source AS
(

	SELECT
		 Business_Unit_Lookup_Id
		,Created_On
		,Type
		,Match_Value
		,Business_Unit
		,Acronym
	FROM {{ ref('BRONZE__TEH_EQUIPMENT_SALES__SIRFIS_BUSINESS_UNIT_LOOKUP') }}
)

,transform_LatestFile AS
(
    SELECT
        MAX(_Filedate) LatestFileDate
    FROM source_data
)

,transform_data as
(
	SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        CASE
        WHEN SourceData.UEID IS NULL THEN TO_VARCHAR(SourceData.ForecastId)
        WHEN SourceData.ForecastId IS NULL THEN TO_VARCHAR(SourceData.UEID)
        ELSE TO_VARCHAR(SourceData.UEID) || '-' || TO_VARCHAR(SourceData.ForecastId)
        END																AS Sirfis_Barcode
        ,CASE WHEN SourceData.PONumber IS NULL THEN 'No' ELSE 'Yes' END		AS Is_Purchase_Order
        ,BULookup.Business_Unit												AS Business_Unit
        ,IFNULL (  SourceData.PONumber , '' )								AS Purchase_Order_Number
        ,IFNULL ( LPAD ( SourceData.POLineNumber , 5 , '0' ) , '' )			AS Purchase_Order_Line_Number
        ,CASE
        WHEN SourceData.POLineNumber IS NULL THEN ''
        ELSE SourceData.PONumber || '-' || LPAD ( SourceData.POLineNumber , 5 , '0' )
        END 																AS Purchase_Order_Key
        ,CASE WHEN SourceData.Impact IS NULL THEN 'No'
        WHEN SourceData.Impact = '' THEN 'No'
        ELSE 'Yes' END														AS Is_Critical
        ,UPPER ( SourceData.StateCode )										AS State
        ,SourceData.TransitTime												AS Transit_Time
        ,SourceData.Site													AS Site
        ,SourceData.Category												AS Category
        ,CASE
        WHEN SourceData.Category = 'PK'  THEN 'PKD'
        WHEN SourceData.Category = 'PKD' THEN 'PKD'
        WHEN SourceData.Category = 'CK'  THEN 'CK'
        WHEN SourceData.Category = 'MT'  THEN 'MT'
        ELSE 'Other'
        END																AS Category_ArfQrf_Key
        ,SourceData.Model													AS Model
        ,SourceData.CEID													AS Copy_Exact_Id
        ,SourceData.EntityCode												AS Entity
        ,SourceData.CapacityProcess											AS Process
        ,SourceData.Description												AS Description
        ,SourceData.Quantity												AS Quantity
        ,SourceData.BuildTime												AS Build_Time
        ,SourceData.SerialNumber											AS Serial_Number
        ,CASE WHEN SourceData.SupplierCSIChildCount IS NULL THEN 'No' ELSE 'Yes' END 	AS Read_Only
        ,SourceData.SupplierMap											AS Supplier_Map
        ,UPPER(SourceData.ConversionLocation)								AS Conversion_Location
        ,TO_DATE(SourceData.ReleaseDate)									AS Intel_Released_Date
        ,TO_DATE(SourceData.RDD)											AS Requested_Delivery_Date
        ,TO_DATE(SourceData.CTD)											AS Contractual_Tender_Date
        ,TO_DATE(SourceData.RTD)											AS Requested_Tender_Date
        ,TO_DATE(SourceData.ResponseSTD)									AS Supplier_Tender_Date
        ,TO_DATE(SourceData.STD)											AS Last_Supplier_Tender_Date
        ,CASE
        WHEN COALESCE(SUPPLIER_TENDER_DATE, LAST_SUPPLIER_TENDER_DATE) IS NOT NULL
        THEN DATEADD(DAY, TRANSIT_TIME, COALESCE(SUPPLIER_TENDER_DATE, LAST_SUPPLIER_TENDER_DATE))
        WHEN COALESCE(SUPPLIER_TENDER_DATE, LAST_SUPPLIER_TENDER_DATE) IS NULL AND CONTRACTUAL_TENDER_DATE IS NOT NULL
        THEN DATEADD(DAY, TRANSIT_TIME, CONTRACTUAL_TENDER_DATE)
        WHEN BUILD_TIME IS NOT NULL AND TRANSIT_TIME IS NOT NULL
        THEN DATEADD(DAY, BUILD_TIME+TRANSIT_TIME, CURRENT_DATE())
        ELSE NULL END AS EXPECTED_SUPPLIER_DELIVERY_DATE
        ,CONCAT( SourceData.Category , '-',
        CASE
        WHEN SourceData.Category  = 'CK' THEN CONCAT(LEFT(SUBSTR(UPPER( SourceData.Description ), 1, CHARINDEX(' TO ', SourceData.Description )),5), '-', TRIM(RIGHT(SUBSTR(UPPER( SourceData.Description ), 1, CHARINDEX(' TO ',  SourceData.Description )),5)), '-')
        ELSE ''
        END
        , UPPER( SourceData.CEID ), '-', SourceData.CapacityProcess ) 	AS Price_Key
        ,BULookup.Acronym													AS Business_Unit_Short_Text
        ,SourceData.UEID													AS UEID
        ,SourceData.ForecastId												AS Id
        ,TO_DATE(COALESCE( SourceData.ResponseSTD ,  SourceData.STD ,  SourceData.RTD ))	AS Primary_Supplier_Tender_Date
        ,CASE
        WHEN SourceData.Category  <> 'NSI' THEN 'No'
        WHEN SourceData.SupplierNumber <> '1000011244' THEN 'No'
        WHEN SourceData.Model RLIKE '^.{6}-.{6}-.{2,3}$' THEN 'Yes'
        WHEN SourceData.Model RLIKE '^.{5}-.{6}-.{1,2}$' THEN 'Yes'
        WHEN SourceData.Model RLIKE '^.{4}-.{6}-.{2,3}$' THEN 'Yes'
        WHEN SourceData.Model RLIKE '^.{3}-.{6}-.{1,2}$' THEN 'Yes'
        ELSE 'No'
        END																AS Is_Part_Order
        ,CASE
        WHEN SourceData.CATEGORY = 'MT' THEN TO_DATE(SourceData.SetStart)
        WHEN SourceData.CATEGORY in ('PK', 'PKD') THEN TO_DATE(SourceData.PrefacStart)
        WHEN SourceData.CATEGORY in ('CK', 'CSI', 'UK') THEN TO_DATE(SourceData.ConvertStart)
        WHEN SourceData.CATEGORY = 'AL' THEN TO_DATE(SourceData.CTD)
        END 															AS SET_START_DATE
        ,SourceData.ReuseCapacityProcess									AS Reuse_Process
        ,SourceData.ReuseEntityCode											AS Reuse_Entity
        ,SourceData.ReuseCEID												AS Reuse_CEID
        ,SourceData.ReuseSite												AS Reuse_Site
        ,CASE WHEN LatestFile.LatestFileDate IS NOT NULL THEN 'Yes' ELSE 'No' END AS Is_In_Latest_File
        ,SourceData._AppendedDate
        ,SourceData.Revision_Desc_Order
        ,SourceData.ACTION
        ,SourceData.ACTIONDATE
        ,SourceData.TRANSITMODE
        ,SourceData.HAND
        --2023-11-15 - Leah QI - TMEA Business Separation From Intel Equipment Sales
        ,SourceData.SupplierNumber
        ,SourceData.ResponseComment
FROM source_data SourceData
	LEFT JOIN Business_Unit_Lookup_Source BULookup ON 
	(UPPER( LEFT( BULookup.Match_Value, 3) ) = UPPER ( LEFT( SourceData.EntityCode, 3) )
	AND UPPER( BULookup.Type ) = 'ENTITY')
	LEFT OUTER JOIN transform_LatestFile LatestFile
    ON LatestFile.LatestFileDate = SourceData._FileDate
)
,type_data as
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(SIRFIS_BARCODE as VARCHAR(16777216)) as SIRFIS_BARCODE,
        cast(IS_PURCHASE_ORDER as VARCHAR(16777216)) as IS_PURCHASE_ORDER,
        cast(BUSINESS_UNIT as VARCHAR(16777216)) as BUSINESS_UNIT,
        cast(PURCHASE_ORDER_NUMBER as VARCHAR(16777216)) as PURCHASE_ORDER_NUMBER,
        cast(PURCHASE_ORDER_LINE_NUMBER as VARCHAR(16777216)) as PURCHASE_ORDER_LINE_NUMBER,
        cast(PURCHASE_ORDER_KEY as VARCHAR(16777216)) as PURCHASE_ORDER_KEY,
        cast(IS_CRITICAL as VARCHAR(16777216)) as IS_CRITICAL,
        cast(STATE as VARCHAR(16777216)) as STATE,
        cast(TRANSIT_TIME as NUMBER(38,0)) as TRANSIT_TIME,
        cast(SITE as VARCHAR(16777216)) as SITE,
        cast(CATEGORY as VARCHAR(16777216)) as CATEGORY,
        cast(CATEGORY_ARFQRF_KEY as VARCHAR(16777216)) as CATEGORY_ARFQRF_KEY,
        cast(MODEL as VARCHAR(16777216)) as MODEL,
        cast(COPY_EXACT_ID as VARCHAR(16777216)) as COPY_EXACT_ID,
        cast(ENTITY as VARCHAR(16777216)) as ENTITY,
        cast(PROCESS as VARCHAR(16777216)) as PROCESS,
        cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
        cast(QUANTITY as NUMBER(38,0)) as QUANTITY,
        cast(BUILD_TIME as VARCHAR(16777216)) as BUILD_TIME,
        cast(SERIAL_NUMBER as VARCHAR(16777216)) as SERIAL_NUMBER,
        cast(READ_ONLY as VARCHAR(16777216)) as READ_ONLY,
        cast(SUPPLIER_MAP as VARCHAR(16777216)) as SUPPLIER_MAP,
        cast(CONVERSION_LOCATION as VARCHAR(16777216)) as CONVERSION_LOCATION,
        cast(INTEL_RELEASED_DATE as DATE) as INTEL_RELEASED_DATE,
        cast(REQUESTED_DELIVERY_DATE as DATE) as REQUESTED_DELIVERY_DATE,
        cast(CONTRACTUAL_TENDER_DATE as DATE) as CONTRACTUAL_TENDER_DATE,
        cast(REQUESTED_TENDER_DATE as DATE) as REQUESTED_TENDER_DATE,
        cast(SUPPLIER_TENDER_DATE as DATE) as SUPPLIER_TENDER_DATE,
        cast(LAST_SUPPLIER_TENDER_DATE as DATE) as LAST_SUPPLIER_TENDER_DATE,
        cast(EXPECTED_SUPPLIER_DELIVERY_DATE as DATE) as EXPECTED_SUPPLIER_DELIVERY_DATE,
        cast(PRICE_KEY as VARCHAR(16777216)) as PRICE_KEY,
        cast(BUSINESS_UNIT_SHORT_TEXT as VARCHAR(16777216)) as BUSINESS_UNIT_SHORT_TEXT,
        cast(UEID as VARCHAR(16777216)) as UEID,
        cast(ID as VARCHAR(16777216)) as ID,
        cast(PRIMARY_SUPPLIER_TENDER_DATE as DATE) as PRIMARY_SUPPLIER_TENDER_DATE,
        cast(IS_PART_ORDER as VARCHAR(16777216)) as IS_PART_ORDER,
        cast(SET_START_DATE as DATE) as SET_START_DATE,
        cast(REUSE_PROCESS as VARCHAR(16777216)) as REUSE_PROCESS,
        cast(REUSE_ENTITY as VARCHAR(16777216)) as REUSE_ENTITY,
        cast(REUSE_CEID as VARCHAR(16777216)) as REUSE_CEID,
        cast(REUSE_SITE as VARCHAR(16777216)) as REUSE_SITE,
        cast(IS_IN_LATEST_FILE as VARCHAR(16777216)) as IS_IN_LATEST_FILE,
        cast(ACTION as VARCHAR(16777216)) as ACTION,
        cast(ACTIONDATE as DATE) as ACTION_DATE,
        cast(TRANSITMODE as VARCHAR(16777216)) as TRANSIT_MODE,
        cast(HAND as VARCHAR(16777216)) as HANDEDNESS,
        cast(Revision_Desc_Order as NUMBER(38,0)) as Revision_Desc_Order,
        cast(_APPENDEDDATE as DATE) as _APPENDEDDATE,
        --2023-11-15 - Leah QI - TMEA Business Separation From Intel Equipment Sales
        cast(SupplierNumber as VARCHAR(16777216)) AS SUPPLIER_NUMBER,
        cast(ResponseComment as VARCHAR(16777216)) AS RESPONSE_COMMENT
from transform_data
    )
select distinct * from type_data