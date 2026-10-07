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
		,requestCancellationFee
		,responseCurrentCancellationFee
		,responseHasNextCancellationFee
		,responseIsPartOfNegotiation
		,_AppendedDate
		,Revision_Desc_Order
	FROM {{ ref('BRONZE__TEH_SALES_TO_INSTALLATION__SIRFIS_SIRFIS_FORECAST_BASE') }}
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
	FROM {{ ref('BRONZE__TEH_SALES_TO_INSTALLATION__SIRFIS_BUSINESS_UNIT_LOOKUP') }}
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
		'{{ invocation_id }}' AS _AUDIT_LOG_ID
		,SHA2('hash_me') AS _ROW_HASH
		, CASE
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
		  --Leah 2025-09-09 IF CK & BU = Test Systems then looking at From CEID To CEID Only Ignore the Process
        , CASE WHEN SourceData.Category  = 'CK' AND BULookup.Acronym = 'TS'
               THEN CONCAT(SourceData.Category, '-', UPPER(SourceData.ReuseCEID),'-', UPPER(SourceData.CEID) )
                -- Rather than parse out, grab the from and to directly 
               WHEN SourceData.Category  = 'CK' AND BULookup.Acronym <> 'TS'
    			THEN CONCAT(SourceData.Category, '-', UPPER(SourceData.ReuseCEID),   '-', SourceData.ReuseCapacityProcess,  '-', UPPER(SourceData.CEID),  '-', SourceData.CapacityProcess)
               ELSE CONCAT(SourceData.Category, '-', UPPER(SourceData.CEID), '-', SourceData.CapacityProcess)
            END AS Price_Key
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
		,SourceData.requestCancellationFee
		,SourceData.responseCurrentCancellationFee
		,SourceData.responseHasNextCancellationFee
		,SourceData.responseIsPartOfNegotiation
		--2023-11-15 - Leah QI - TMEA Business Separation From Intel Equipment Sales
		,SourceData.SupplierNumber as supplier_number
		,SourceData.ResponseComment as response_comment
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
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        SIRFIS_BARCODE,
        IS_PURCHASE_ORDER,
        BUSINESS_UNIT,
        PURCHASE_ORDER_NUMBER,
        PURCHASE_ORDER_LINE_NUMBER,
        PURCHASE_ORDER_KEY,
        IS_CRITICAL,
        STATE,
        cast(TRANSIT_TIME as NUMBER(38,0)) as TRANSIT_TIME,
        SITE,
        CATEGORY,
        CATEGORY_ARFQRF_KEY,
        MODEL,
        COPY_EXACT_ID,
        ENTITY,
        PROCESS,
        DESCRIPTION,
        cast(QUANTITY as NUMBER(38,0)) as QUANTITY,
        BUILD_TIME,
        SERIAL_NUMBER,
        READ_ONLY,
        SUPPLIER_MAP,
        CONVERSION_LOCATION,
        cast(INTEL_RELEASED_DATE as DATE) as INTEL_RELEASED_DATE,
        cast(REQUESTED_DELIVERY_DATE as DATE) as REQUESTED_DELIVERY_DATE,
        cast(CONTRACTUAL_TENDER_DATE as DATE) as CONTRACTUAL_TENDER_DATE,
        cast(REQUESTED_TENDER_DATE as DATE) as REQUESTED_TENDER_DATE,
        cast(SUPPLIER_TENDER_DATE as DATE) as SUPPLIER_TENDER_DATE,
        cast(LAST_SUPPLIER_TENDER_DATE as DATE) as LAST_SUPPLIER_TENDER_DATE,
        cast(EXPECTED_SUPPLIER_DELIVERY_DATE as DATE) as EXPECTED_SUPPLIER_DELIVERY_DATE,
        PRICE_KEY,
        BUSINESS_UNIT_SHORT_TEXT,
        UEID,
        ID,
        cast(PRIMARY_SUPPLIER_TENDER_DATE as DATE) as PRIMARY_SUPPLIER_TENDER_DATE,
        IS_PART_ORDER,
		cast(SET_START_DATE as DATE) as SET_START_DATE,
        REUSE_PROCESS,
        REUSE_ENTITY,
        REUSE_CEID,
        REUSE_SITE,
        IS_IN_LATEST_FILE,
		ACTION,
        cast(ACTIONDATE as DATE) as ACTION_DATE,
        TRANSITMODE as TRANSIT_MODE,
        Hand as HANDEDNESS,
		requestCancellationFee::BOOLEAN as requestCancellationFee,
		responseCurrentCancellationFee::NUMBER(38,0) as responseCurrentCancellationFee,
		responseHasNextCancellationFee::BOOLEAN as responseHasNextCancellationFee,
		responseIsPartOfNegotiation::BOOLEAN as responseIsPartOfNegotiation,
		cast(Revision_Desc_Order as NUMBER(38,0)) as Revision_Desc_Order,		
		cast(_APPENDEDDATE as DATE) as _APPENDEDDATE, 
		--2023-11-15 - Leah QI - TMEA Business Separation From Intel Equipment Sales
		SUPPLIER_NUMBER, 
		RESPONSE_COMMENT
    from transform_data
    )
select distinct * from type_data