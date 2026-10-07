{{ config(
       materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='INTEL_PURCHASE_ORDER_CHANGE_ORDER_HISTORY', 
	unique_key=['PURCHASE_ORDER_LINE_ID', 'REVISION_NUMBER']
) }}

with source_Header AS
(
	select *
	from {{ ref('BRONZE__TEH_SALES_TO_INSTALLATION__TELCUSTOMER_CAPITAL_PO_HEADER') }}
)
, source_Line AS
(
	SELECT *
	from {{ ref('BRONZE__TEH_SALES_TO_INSTALLATION__TELCUSTOMER_CAPITAL_PO_LINE') }}
)
, source_ShipToLocation AS
(
    SELECT
         Ship_To_Location_Id
        ,BAAN_BPId
    FROM {{ ref('BRONZE__TEH_SALES_TO_INSTALLATION__TELCUSTOMER_CAPITAL_PO_SHIP_TO_LOCATION') }}
)
, source_ShipToDescription AS
(
    SELECT
         BAAN_BPId
        ,DESCR
    FROM {{ ref('BRONZE__TEH_SALES_TO_INSTALLATION__TELCUSTOMER_CAPITAL_PO_SHIP_TO_DESCR') }}
)
, source_EventTracking AS
(
    SELECT
         PO_Number
        ,Rev
        ,UserId
        ,Action_Date
        ,Event_Type
        ,Old_Status
        ,New_Status
    FROM {{ ref('BRONZE__TEH_SALES_TO_INSTALLATION__TELCUSTOMER_CAPITAL_PO_EVENT_TRACKING') }}
)
/**************  TRANSFORMS **************/
, transform_Header AS
(
	SELECT DISTINCT
	    MESSAGE_ID
		, Account_Number
		,Bill_To_Location_Id
		,UPPER(Bill_to_Name) AS Bill_to_Name
		,CONCAT(Bill_To_Address_1, ' ', Bill_To_Address_2, ' ', Bill_To_Address_3, ' ', Bill_To_Postal_Code) AS Bill_To_Address
		,UPPER(Bill_To_City) AS Bill_to_City
		,UPPER(Bill_to_Region) AS Bill_To_Region
		,CASE
			WHEN UPPER(Bill_To_Country) = 'CN' THEN 'CHINA'
			WHEN UPPER(Bill_To_Country) = 'IE' THEN 'IRELAND'
			WHEN UPPER(Bill_To_Country) = 'IL' THEN 'ISRAEL'
			WHEN UPPER(Bill_To_Country) = 'JP' THEN 'JAPAN'
			WHEN UPPER(Bill_To_Country) = 'MY' THEN 'MALAYSIA'
			WHEN UPPER(Bill_To_Country) = 'US' THEN 'USA'
			ELSE UPPER(Bill_To_Country)
			END AS Bill_To_Country
		,UPPER(NULLIF(COALESCE(BU,'') || COALESCE(' ' ||  Sub_BU,''),'')) Business_Unit
		,UPPER(Currency) AS Currency
		,UPPER(Prov_Status) AS Prov_Status
		,Reason
		,CASE WHEN Part_Order = 1 THEN 'Yes' ELSE 'No' END AS Is_Part_Order
		,Data_Load_Date
		,Net_Terms_Days
		,UPPER(Overall_Status) AS Overall_Status
		,BU AS Original_Business_Unit
		,Percent_Due
		,PO_Number
		,PO_Date
		,UPPER(PO_Type) AS PO_Type
		,UPPER(Purchasing_Type) AS Purchasing_Type
		,CASE
			WHEN PIP = '3A4' THEN 'Purchase Order'
			WHEN PIP = '3A8' THEN 'Change Order'
			ELSE 'N/A'
		 END AS Record_Type
		,CASE
			WHEN PIP = '3A4' THEN 'PO'
			WHEN PIP = '3A8' THEN 'CO'
			ELSE 'N/A'
		 END AS Record_Type_Short_Text
		,Rev
		,Sub_BU AS Sub_Business_Unit
		,UPPER(TEL_PO_Status) AS TEL_PO_Status
		,Amount
		,Comments
        ,case when Comments like '%ANY QUOTATION NUMBER OR ANY OTHER REFERENCE TO A QUOTATION ON THIS PURCHASE ORDER IS FOR REFERENCE PURPOSES ONLY AND THE QUOTATION TERMS AND CONDITIONS WILL NOT BE LEGALLY BINDING ON EITHER PARTY. BY SHIPPING ITEMS OR PERFORMING SERVICES DESCRIBED IN THIS PURCHASE ORDER, SUPPLIER THEREBY ACCEPTS BUYER\'S TERMS AND CONDITIONS STATED ON THIS PURCHASE ORDER AND WITHDRAWS ANY OTHER TERMS AND CONDITIONS DESCRIBED IN SUPPLIER\'S DOCUMENTS OR SUPPLIER\'S ELECTRONIC ORDERING SYSTEMS. IN THE EVENT OF THE EXISTENCE OF ANY OTHER AGREEMENTS BETWEEN THE PARTIES, THE PRICE FOR ITEMS AND SERVICES DESCRIBED IN THIS PURCHASE ORDER WILL BE THE LESSER OF SUPPLIER\'S QUOTED PRICE, OR THE PRICE DESCRIBED IN SUCH OTHER AGREEMENTS BETWEEN THE PARTIES. IF YOU HAVE QUESTIONS REGARDING THE P.O. DESCRIPTIONS, PRICE INQUIRIES, PAYMENT TERMS, ETC; PLEASE CONTACT: YOUR INTEL BUYER .%'
            then 
        replace(comments,'ANY QUOTATION NUMBER OR ANY OTHER REFERENCE TO A QUOTATION ON THIS PURCHASE ORDER IS FOR REFERENCE PURPOSES ONLY AND THE QUOTATION TERMS AND CONDITIONS WILL NOT BE LEGALLY BINDING ON EITHER PARTY. BY SHIPPING ITEMS OR PERFORMING SERVICES DESCRIBED IN THIS PURCHASE ORDER, SUPPLIER THEREBY ACCEPTS BUYER\'S TERMS AND CONDITIONS STATED ON THIS PURCHASE ORDER AND WITHDRAWS ANY OTHER TERMS AND CONDITIONS DESCRIBED IN SUPPLIER\'S DOCUMENTS OR SUPPLIER\'S ELECTRONIC ORDERING SYSTEMS. IN THE EVENT OF THE EXISTENCE OF ANY OTHER AGREEMENTS BETWEEN THE PARTIES, THE PRICE FOR ITEMS AND SERVICES DESCRIBED IN THIS PURCHASE ORDER WILL BE THE LESSER OF SUPPLIER\'S QUOTED PRICE, OR THE PRICE DESCRIBED IN SUCH OTHER AGREEMENTS BETWEEN THE PARTIES. IF YOU HAVE QUESTIONS REGARDING THE P.O. DESCRIPTIONS, PRICE INQUIRIES, PAYMENT TERMS, ETC; PLEASE CONTACT: YOUR INTEL BUYER .','')
        when comments like '%ANY QUOTATION NUMBER OR ANY OTHER REFERENCE TO A QUOTATION ON THIS PURCHASE ORDER IS FOR REFERENCE PURPOSES ONLY AND THE QUOTATION TERMS AND CONDITIONS WILL NOT BE LEGALLY BINDING ON EITHER PARTY. BY SHIPPING ITEMS OR PERFORMING SERVICES DESCRIBED IN THIS PURCHASE ORDER, SUPPLIER THEREBY ACCEPTS BUYER\'S TERMS AND CONDITIONS STATED ON THIS PURCHASE ORDER AND WITHDRAWS ANY OTHER TERMS AND CONDITIONS DESCRIBED IN SUPPLIER\'S DOCUMENTS OR SUPPLIER\'S ELECTRONIC ORDERING SYSTEMS. IN THE EVENT OF THE EXISTENCE OF ANY OTHER AGREEMENTS BETWEEN THE PARTIES, THE PRICE FOR ITEMS AND SERVICES DESCRIBED IN THIS PURCHASE ORDER WILL BE THE LESSER OF SUPPLIER\'S QUOTED PRICE, OR THE PRICE DESCRIBED IN SUCH OTHER AGREEMENTS BETWEEN THE PARTIES. IF YOU HAVE QUESTIONS REGARDING THE P.O. DESCRIPTIONS, PRICE INQUIRIES, PAYMENT TERMS, ETC; PLEASE CONTACT: YOUR INTEL BUYER PLEASE READ TERMS AND CONDITIONS. OTHERWISE DIRECT TO YOUR INTEL BUYER. FOR CHINA AND VIETNAM ORDERS ONLY: IT IS ESSENTIAL THAT ALL DOLLAR AMOUNTS, SUPPLIER NAME, ITEM DESCRIPTIONS, AND ALL OTHER PERTINENT DATA ON BOTH THE COMMERCIAL INVOI CE AND SHIPPING INVOICE ARE ACCURATE AND MATCHING. FAILURE TO DO SO WILL RESULT IN CDS DOCUMENTATION ERRORS AND SUBSEQUENT PAYMENT DELAYS. IF PROVIDING A SERVICE CONSUMED AND PERFORMED OUTSIDE OF THE COUNTRY, YOU WILL NEED TO ACCURATELY INDICATE THIS IN YOUR BILLING DOCUMENTS/INVOICE. FOR PROPER CUSTOMS CLEARANCE AND PAYMENT PROCESSING, THE SERIAL NUMBER SHOULD BE DOCUMENTED ON THE SHIPPING/COMMERCIAL INVOICE AND PACKING LIST AND AN ADDENDUM MUST BE COMPLETED FOR ANY LINE ITEM THAT HAS KIT, ASSEMBLY (ASSY) OR SET IN THE DESCRIPTION. .%'
            then 
        replace(comments,'ANY QUOTATION NUMBER OR ANY OTHER REFERENCE TO A QUOTATION ON THIS PURCHASE ORDER IS FOR REFERENCE PURPOSES ONLY AND THE QUOTATION TERMS AND CONDITIONS WILL NOT BE LEGALLY BINDING ON EITHER PARTY. BY SHIPPING ITEMS OR PERFORMING SERVICES DESCRIBED IN THIS PURCHASE ORDER, SUPPLIER THEREBY ACCEPTS BUYER\'S TERMS AND CONDITIONS STATED ON THIS PURCHASE ORDER AND WITHDRAWS ANY OTHER TERMS AND CONDITIONS DESCRIBED IN SUPPLIER\'S DOCUMENTS OR SUPPLIER\'S ELECTRONIC ORDERING SYSTEMS. IN THE EVENT OF THE EXISTENCE OF ANY OTHER AGREEMENTS BETWEEN THE PARTIES, THE PRICE FOR ITEMS AND SERVICES DESCRIBED IN THIS PURCHASE ORDER WILL BE THE LESSER OF SUPPLIER\'S QUOTED PRICE, OR THE PRICE DESCRIBED IN SUCH OTHER AGREEMENTS BETWEEN THE PARTIES. IF YOU HAVE QUESTIONS REGARDING THE P.O. DESCRIPTIONS, PRICE INQUIRIES, PAYMENT TERMS, ETC; PLEASE CONTACT: YOUR INTEL BUYER PLEASE READ TERMS AND CONDITIONS. OTHERWISE DIRECT TO YOUR INTEL BUYER. FOR CHINA AND VIETNAM ORDERS ONLY: IT IS ESSENTIAL THAT ALL DOLLAR AMOUNTS, SUPPLIER NAME, ITEM DESCRIPTIONS, AND ALL OTHER PERTINENT DATA ON BOTH THE COMMERCIAL INVOI CE AND SHIPPING INVOICE ARE ACCURATE AND MATCHING. FAILURE TO DO SO WILL RESULT IN CDS DOCUMENTATION ERRORS AND SUBSEQUENT PAYMENT DELAYS. IF PROVIDING A SERVICE CONSUMED AND PERFORMED OUTSIDE OF THE COUNTRY, YOU WILL NEED TO ACCURATELY INDICATE THIS IN YOUR BILLING DOCUMENTS/INVOICE. FOR PROPER CUSTOMS CLEARANCE AND PAYMENT PROCESSING, THE SERIAL NUMBER SHOULD BE DOCUMENTED ON THE SHIPPING/COMMERCIAL INVOICE AND PACKING LIST AND AN ADDENDUM MUST BE COMPLETED FOR ANY LINE ITEM THAT HAS KIT, ASSEMBLY (ASSY) OR SET IN THE DESCRIPTION. .','')
            else Comments
        end as comments_filtered
		,Net_Terms_Days2
		,Percent_Due2
	FROM source_Header
)


, transform_Line AS
(
	SELECT DISTINCT
	    MESSAGE_ID
		,PO_Number
		,Rev
		,Line_Number
		,Sub_Line_Number
		,Capital_Category_Code AS Category
		,CASE
			WHEN  Capital_Category_Code = 'Conversion Kit' THEN 'CK'
			WHEN  Capital_Category_Code = 'Pre-Facility Kit' THEN 'PK'
			WHEN  Capital_Category_Code = 'Major Tool' THEN 'MT'
		 END AS Category_Short_Text
		,Copy_Exact_Id
		,Customer_Item_Number
		,Entity_Code
		,UPPER(Fob_Code) AS Fob_Code
		,UPPER(Inco_Term) AS Inco_Term
		,UPPER(Item_Description) AS Item_Description
		,Item_Number
		,Amount
		,UPPER(Prov_Status) AS Prov_Status
		,Reason
		,UPPER(Internal_Model_Identifier) AS Internal_Model_Identifier
		,Technology_Code
		,UPPER(Action_Code) AS Action_Code
		,QRF_Quote_Id
		,COALESCE(Item_Number,Quote_Number) AS Quote_Id
		,Quote_Number
		,QTY
		,Requested_Unit_Price
        ,TRY_TO_DATE(Requested_Tender_Date,'mm/dd/yy') AS Requested_Tender_Date
		,Last_Modified_By_DT
		,UPPER(Shipping_Condition) AS Shipping_Condition
		,UPPER(Shipping_Service_Level_Code) AS Shipping_Service_Level_Code
		,UPPER(Ship_To_Name) AS Ship_To_Name
		,CONCAT(coalesce(Ship_To_Address_1, ''), ' ', coalesce(Ship_To_Address_2, ''), ' ', coalesce(Ship_To_Address_3, ''), ' ', coalesce(Ship_To_Postal_Code, '')) AS Ship_To_Address
		,UPPER(Ship_To_City) AS Ship_To_City
		,UPPER(Ship_To_Region) AS Ship_To_Region
		,CASE
			WHEN UPPER(Ship_To_Country) = 'CN' THEN 'CHINA'
			WHEN UPPER(Ship_To_Country) = 'IE' THEN 'IRELAND'
			WHEN UPPER(Ship_To_Country) = 'IL' THEN 'ISRAEL'
			WHEN UPPER(Ship_To_Country) = 'JP' THEN 'JAPAN'
			WHEN UPPER(Ship_To_Country) = 'MY' THEN 'MALAYSIA'
			WHEN UPPER(Ship_To_Country) = 'US' THEN 'USA'
			ELSE UPPER(Ship_To_Country)
			END AS Ship_To_Country
        ,Ship_To_Location_ID
		,UPPER(Special_Handling_Instruction) AS Special_Handling_Instruction
		,Tax_Exempt
		,Tax_Exempt_Code
		,UPPER(TEL_Line_Status) AS TEL_Line_Status
		,UPPER(UOM) AS UOM
		,TO_DATE(Requested_Date) AS Requested_Date
        ,DETECTED_QUOTE_NUMBER
	from source_Line
)
, transform_ShipToLocation AS
(
    SELECT
         Ship_To_Location_Id
        ,BAAN_BPId AS Baan_BusinessPartner_Id
    FROM source_ShipToLocation
)
, transform_ShipToDescription AS
(
    SELECT
         BAAN_BPId AS Baan_BusinessPartner_Id
        ,DESCR AS Description
    FROM source_ShipToDescription
)
, transform_EventTracking AS
(
    SELECT
         PO_Number
        ,Rev
        ,UserId
        ,TO_DATE(Action_Date) AS Action_Date
        ,Action_Date AS Action_Datetime
        ,Event_Type
        ,Old_Status
        ,New_Status
    FROM source_EventTracking
)
, transform_FirstPOAcceptance AS
(
    SELECT
        PO_Number
        ,MIN(Rev) AS Minimum_Rev
        ,MIN(Action_Date) AS Minimum_ActionDate
        ,MIN(Action_Datetime) AS Minimum_ActionDatetime
    FROM transform_EventTracking
    WHERE Event_Type = 'Submit'
        AND New_Status = 'Accepted'
        AND Action_Date IS NOT NULL
    GROUP BY PO_Number
)
, transform_FirstPOSubmit AS
(
    SELECT
         PO_Number
        ,Rev
        ,MIN(Action_Datetime) AS Submit_ActionDatetime
    FROM transform_EventTracking
    WHERE Event_Type = 'Submit'
        AND Action_Date IS NOT NULL
	GROUP BY PO_Number, Rev
)
, combine_datasets AS
(
    SELECT DISTINCT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID
        ,SHA2('hash_me') AS _ROW_HASH
        ,Header.PO_Number||'-'||LPAD(Line.Line_Number,5,'0')     			AS PURCHASE_ORDER_LINE_ID
        ,Header.PO_Number               									AS Purchase_Order_Number
        ,Line.Line_Number               									AS Purchase_Order_Line_Number
        ,Header.Rev         												AS REVISION_NUMBER
        ,Line.Item_Number               									AS Item_Number
        ,Line.Quote_Number              									AS Quote_Number
        ,Header.Record_Type_Short_Text  									AS Record_Type_Short_Text
        ,Header.Record_Type             									AS Record_Type
        ,Header.PO_Date                										AS Purchase_Order_Timestamp
        ,Header.Data_Load_Date          									AS Load_Timestamp
        ,Line.Last_Modified_By_Dt       									AS Revision_Timestamp
        ,Header.PO_Type                 									AS Purchase_Order_Type
        ,Header.Purchasing_Type         									AS Purchase_Type
        ,Header.Net_Terms_Days          									AS Net_Terms_Days
        ,Header.Percent_Due             									AS Percent_Due
        ,Line.Qty                       									AS Requested_Qty
        ,Line.UOM                       									AS Unit_Of_Measure
        ,Line.Fob_Code                  									AS Freight_On_Board
        ,Line.Inco_Term                 									AS Inco_Term
        ,Header.Currency                									AS Currency
        ,Line.Requested_Unit_Price      									AS Requested_Unit_Price
        ,Line.Amount                    									AS Line_Amount
        ,Header.Amount                  									AS Total_Amount
        ,Line.Tax_Exempt                									AS Tax_Exempt
        ,Line.Tax_Exempt_Code           									AS Tax_Exempt_Code
        ,Line.Customer_Item_Number      									AS Customer_Item_Number
        ,Header.Account_Number          									AS Account_Number
        ,Line.Quote_Id                  									AS Quote_Id
        ,Line.Item_Description          									AS Item_Description
        ,Line.QRF_Quote_Id              									AS QRF_Quote_Id
        ,Header.Comments                  									AS Comments
        ,Header.comments_filtered                                           AS comments_filtered
        ,Line.Action_Code               									AS Purchase_Order_Line_Status
        ,Header.Prov_Status             									AS Header_Prov_Status
        ,Header.Overall_Status          									AS Overall_Status
        ,Line.Prov_Status               									AS Line_Prov_Status
		,Line.Tel_Line_Status												AS Tel_Line_Status
        ,Header.Reason                  									AS Header_Reason
        ,Line.Reason                    									AS Line_Reason
        ,Header.Business_Unit           									AS Business_Unit
        ,Line.Category_Short_Text       									AS Category_Short_Text
        ,Line.Category                  									AS Category
        ,STDescription.Description      									AS Site
        ,Line.Internal_Model_Identifier 									AS Model
        ,Line.Copy_Exact_Id             									AS Copy_Exact_Id
        ,Line.Entity_Code               									AS Entity
        ,Line.Technology_Code           									AS Process
        ,Line.Ship_To_Name              									AS Shipping_To_Name
        ,Line.Shipping_Service_Level_Code 									AS Shipping_Service_Level_Code
        ,Line.Ship_To_Country           									AS Ship_to_Country
        ,Line.Ship_To_Region            									AS Ship_To_Region
        ,Line.Ship_To_City              									AS Ship_To_City
        ,Line.Shipping_Condition        									AS Shipping_Condition
        ,Line.Ship_To_Address           									AS Ship_To_Address
        ,Line.Special_Handling_Instruction         							AS Special_Handling_Instruction
        ,Header.Bill_To_Name                       							AS Bill_To_Name
        ,Header.Bill_To_Country                     						AS Bill_To_Country
        ,Header.Bill_To_Region                      						AS Bill_To_Region
        ,Header.Bill_To_City                        						AS Bill_To_City
        ,Header.Bill_To_Location_Id                 						AS Bill_To_Location_Id
        ,Header.Bill_To_Address                     						AS Bill_To_Address
        ,FirstPOAcceptance.Minimum_ActionDatetime   						AS Purchase_Order_Acceptance_Datetime
        ,FirstPOAcceptance.Minimum_ActionDate      							AS Purchase_Order_Acceptance_Date
        ,FirstPOAcceptance.Minimum_Rev             							AS Purchase_Order_Acceptance_Revision_Number
        ,Header.Is_Part_Order                      							AS Is_Part_Order
        ,Header.TEL_PO_Status                      							AS TEL_Header_Status
        ,Line.Requested_Tender_Date                							AS Requested_Tender_Date
        ,Header.Original_Business_Unit             							AS Original_Business_Unit
        ,Header.Sub_Business_Unit                  							AS Sub_Business_Unit
        ,FirstPOSubmit.Submit_ActionDatetime       							AS Purchase_Order_Rev_Action_Timestamp
		,line.Requested_Date												AS Requested_Date
		,Header.Net_Terms_Days2												AS Net_Terms_Days2
		,Header.Percent_Due2												AS Percent_Due2
        ,Line.DETECTED_QUOTE_NUMBER              							AS DETECTED_QUOTE_NUMBER
    FROM transform_Header Header
-- LQI REVISED on 2024_09_11 using PO & REV join both header & line as per Paul Benson - IT IS Team is joined the same way
    INNER JOIN transform_Line Line
    --ON Header.MESSAGE_ID = Line.MESSAGE_ID
    ON Header.PO_Number = Line.PO_Number
    AND Header.Rev = Line.Rev
    LEFT JOIN transform_ShipToLocation STLocation
     ON STLocation.Ship_To_Location_Id = Line.Ship_To_Location_Id
    LEFT JOIN transform_ShipToDescription STDescription
     ON STDescription.Baan_BusinessPartner_Id = STLocation.Baan_BusinessPartner_Id
    LEFT JOIN transform_FirstPOAcceptance FirstPOAcceptance
     ON FirstPOAcceptance.PO_Number = Header.PO_Number
    LEFT JOIN transform_FirstPOSubmit FirstPOSubmit
     ON FirstPOSubmit.PO_Number = Header.PO_Number
     AND FirstPOSubmit.Rev = Header.Rev
), 
type_data AS ( 
    SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(16777216)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(16777216)) AS _ROW_HASH,
		PURCHASE_ORDER_LINE_ID,
		Purchase_Order_Number,
		CAST(Purchase_Order_Line_Number AS VARCHAR(16777216)) AS Purchase_Order_Line_Number,
		CAST(REVISION_NUMBER AS NUMBER(38,0)) AS REVISION_NUMBER,
		Item_Number,
		Quote_Number,
		Record_Type_Short_Text,
		Record_Type,
		CAST(Purchase_Order_Timestamp AS TIMESTAMP_NTZ(9)) AS Purchase_Order_Timestamp,
		CAST(Load_Timestamp AS TIMESTAMP_NTZ(9)) AS Load_Timestamp,
		CAST(Revision_Timestamp AS TIMESTAMP_NTZ(9)) AS Revision_Timestamp,
		Purchase_Order_Type,
		Purchase_Type,
		CAST(Net_Terms_Days AS NUMBER(38,0)) AS Net_Terms_Days,
		CAST(Percent_Due AS NUMBER(38,0)) AS Percent_Due,
		CAST(Requested_Qty AS NUMBER(38,0)) AS Requested_Qty,
		Unit_Of_Measure,
		Freight_On_Board,
		Inco_Term,
		Currency,
		CAST(Requested_Unit_Price AS NUMBER(38,0)) AS Requested_Unit_Price,
		CAST(Line_Amount AS NUMBER(38,0)) AS Line_Amount,
		CAST(Total_Amount AS NUMBER(38,0)) AS Total_Amount,
		Tax_Exempt,
		Tax_Exempt_Code,
		Customer_Item_Number,
		Account_Number,
		Quote_Id,
		Item_Description,
		QRF_Quote_Id,
		Comments,
		comments_filtered,
		Purchase_Order_Line_Status,
		Header_Prov_Status,
		Overall_Status,
		Line_Prov_Status,
		Tel_Line_Status,
		Header_Reason,
		Line_Reason,
		Business_Unit,
		Category_Short_Text,
		Category,
		Site,
		Model,
		Copy_Exact_Id,
		Entity,
		Process,
		Shipping_To_Name,
		Shipping_Service_Level_Code,
		Ship_to_Country,
		Ship_To_Region,
		Ship_To_City,
		Shipping_Condition,
		Ship_To_Address,
		Special_Handling_Instruction,
		Bill_To_Name,
		Bill_To_Country,
		Bill_To_Region,
		Bill_To_City,
		Bill_To_Location_Id,
		Bill_To_Address,
		CAST(Purchase_Order_Acceptance_Datetime AS TIMESTAMP_NTZ(9)) AS Purchase_Order_Acceptance_Datetime,
		CAST(Purchase_Order_Acceptance_Date AS DATE) AS Purchase_Order_Acceptance_Date,
		CAST(Purchase_Order_Acceptance_Revision_Number AS NUMBER(38,0)) AS Purchase_Order_Acceptance_Revision_Number,
		Is_Part_Order,
		TEL_Header_Status,
		CAST(Requested_Tender_Date AS DATE) AS Requested_Tender_Date,
		Original_Business_Unit,
		Sub_Business_Unit,
		CAST(Purchase_Order_Rev_Action_Timestamp AS TIMESTAMP_NTZ(9)) AS Purchase_Order_Rev_Action_Timestamp,
		CAST(Requested_Date AS DATE) AS Requested_Date,
		CAST(Net_Terms_Days2 AS NUMBER(38,0)) AS Net_Terms_Days2,
		CAST(Percent_Due2 AS NUMBER(38,2)) AS Percent_Due2,
		DETECTED_QUOTE_NUMBER
    FROM combine_datasets
),
FINAL AS (
    SELECT * , 
        ROW_NUMBER() OVER (PARTITION BY PURCHASE_ORDER_LINE_ID ORDER BY REVISION_NUMBER::NUMBER(38,0) DESC) AS REVISION_DESC_ORDER
    FROM type_data
)
SELECT * FROM FINAL

