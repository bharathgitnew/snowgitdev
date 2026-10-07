/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Carma\REQUESTSERVICE__CARMA_REQUESTSERVICE.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\carma\REQUEST_SERVICE.SQL 
-materialized incremental
-alias REQUEST_SERVICE 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema CARMA
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/10/2022 2:23:24 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='TPL_SHIP_REQUEST',
    unique_key = ['DOCUMENT_NUMBER',
    'LINE_NUMBER']
) }}


with source_data as 
(
    SELECT JSONFIELD:"Document_Number"::STRING AS Document_Number, 
         JSONFIELD:"Line_Number"::NUMBER AS Line_Number, 
         JSONFIELD:"Bill_To_Address_Name_1"::STRING AS Bill_To_Address_Name_1, 
         JSONFIELD:"Bill_To_Address_Name_2"::STRING  AS Bill_To_Address_Name_2, 
         JSONFIELD:"Bill_To_Address_Street_1"::STRING  AS Bill_To_Address_Street_1, 
         JSONFIELD:"Bill_To_Address_Street_2"::STRING AS Bill_To_Address_Street_2, 
         JSONFIELD:"Bill_To_Address_City"::STRING AS Bill_To_Address_City, 
         JSONFIELD:"Bill_To_Address_State"::STRING  AS Bill_To_Address_State, 
         JSONFIELD:"Bill_To_Address_ZIP"::STRING AS Bill_To_Address_ZIP, 
         JSONFIELD:"Bill_To_Address_Country"::STRING AS Bill_To_Address_Country, 
         JSONFIELD:"Ship_To_Address_Name_1"::STRING AS Ship_To_Address_Name_1, 
         JSONFIELD:"Ship_To_Address_Name_2"::STRING AS Ship_To_Address_Name_2, 
         JSONFIELD:"Ship_To_Address_Street_1"::STRING  AS Ship_To_Address_Street_1, 
         JSONFIELD:"Ship_To_Address_Street_2"::STRING  AS Ship_To_Address_Street_2,
         JSONFIELD:"Ship_To_Address_City"::STRING AS Ship_To_Address_City,
         JSONFIELD:"Ship_To_Address_State"::STRING AS Ship_To_Address_State,
         JSONFIELD:"Ship_To_Address_ZIP"::STRING AS Ship_To_Address_ZIP,
         JSONFIELD:"Ship_To_Address_Country"::STRING AS Ship_To_Address_Country,
         JSONFIELD:"Customer_Contact"::STRING AS Customer_Contact,
         JSONFIELD:"Customer_Contact_Phone"::STRING AS Customer_Contact_Phone,
         JSONFIELD:"Customer_Tax_Code"::STRING AS Customer_Tax_Code,   
         JSONFIELD:"Customer_VAT_Registration_Number"::STRING AS Customer_VAT_Registration_Number,
         JSONFIELD:"Order_Number"::STRING AS Order_Number,
         JSONFIELD:"Order_Line_Number"::INT AS Order_Line_Number,
         JSONFIELD:"Customer_PO_Number"::STRING AS Customer_PO_Number,   
         JSONFIELD:"Customer_PO_Line_Number"::STRING AS Customer_PO_Line_Number,
         JSONFIELD:"Material_number"::STRING AS Material_number,
         JSONFIELD:"Part_Description"::STRING AS Part_Description,
         JSONFIELD:"Price"::STRING AS Price, 
         JSONFIELD:"Currency"::STRING AS Currency,
         JSONFIELD:"Ship_Quantity"::INT AS Ship_Quantity,
         JSONFIELD:"Shipment_Carrier"::STRING AS Shipment_Carrier, 
         JSONFIELD:"Shipment_Route"::STRING AS Shipment_Route,
         JSONFIELD:"Order_Priority"::STRING AS Order_Priority,
         JSONFIELD:"Storage_Location"::STRING AS Storage_Location, 
         TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Ship_Date" ,'/Date()/')) AS Ship_Date,
         JSONFIELD:"Header_Text"::STRING AS Header_Text,
         JSONFIELD:"Line_Text"::STRING AS Line_Text,
         JSONFIELD:"Commercial_Invoice_Number"::STRING AS Commercial_Invoice_Number,
         JSONFIELD:"Customer_Part_Number"::STRING AS Customer_Part_Number,
         JSONFIELD:"Country_of_Origin"::STRING AS Country_of_Origin,
         JSONFIELD:"Dual_Use"::INT AS Dual_Use,    
         JSONFIELD:"ECCN_Number"::STRING AS ECCN_Number,
         JSONFIELD:"Shippers_HTS_Code"::STRING AS Shippers_HTS_Code,
         JSONFIELD:"Receivers_HTS_Code"::STRING AS Receivers_HTS_Code,
         JSONFIELD:"Hazardous_Goods"::INT AS Hazardous_Goods,
         JSONFIELD:"Chemical_Flag"::STRING AS Chemical_Flag,
         JSONFIELD:"UN_Number"::STRING AS UN_Number,
         JSONFIELD:"Incoterms"::STRING AS Incoterms, 
         JSONFIELD:"License_Number"::STRING AS License_Number, 
         JSONFIELD:"AES_Citation"::STRING AS AES_Citation, 
         JSONFIELD:"AES_Filing_Date"::STRING AS AES_Filing_Date, 
         JSONFIELD:"AES_Special_Instructions"::STRING AS AES_Special_Instructions, 
         JSONFIELD:"Trading_Partner"::STRING AS Trading_Partner, 
         TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Load_Dt" ,'/Date()/')) AS Load_Dt, 
         JSONFIELD:"Processed"::INT AS Processed, 
         TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Process_Dt" ,'/Date()/')) AS Process_Dt, 
         JSONFIELD:"Error"::BOOLEAN AS Error,
         JSONFIELD:"Error_Message"::STRING AS Error_Message, 
         JSONFIELD:"Process_Id"::INT AS Process_Id,
         JSONFIELD:"Delivery_Type"::STRING AS Delivery_Type, 
         JSONFIELD:"Receiving_Storage_Location"::STRING AS Receiving_Storage_Location,
         JSONFIELD:"Schedule_Line_Number"::STRING AS Schedule_Line_Number,
         _FileDate
    FROM {{ source("THREEPL", "TPL_SHIP_REQUEST") }}  
    {% if is_incremental() %} WHERE _FileDate > IFNULL((SELECT MAX(_FileDate) FROM {{ this }}),'1970-01-01') {% endif %}
	QUALIFY (ROW_NUMBER() OVER (PARTITION BY Document_Number,Line_Number ORDER BY _Filedate DESC )) = 1
)
,transform_data as
(
    SELECT 
	   source_data.Document_Number AS Document_Number
      ,TRY_TO_NUMBER(source_data.Line_Number,38,0) AS Line_Number
      ,source_data.Bill_To_Address_Name_1 AS  Bill_To_Address_Name_1
      ,source_data.Bill_To_Address_Name_2 AS  Bill_To_Address_Name_2
      ,source_data.Bill_To_Address_Street_1 AS Bill_To_Address_Street_1
      ,source_data.Bill_To_Address_Street_2 AS Bill_To_Address_Street_2
      ,source_data.Bill_To_Address_City AS Bill_To_Address_City
      ,source_data.Bill_To_Address_State AS Bill_To_Address_State
      ,source_data.Bill_To_Address_ZIP AS Bill_To_Address_ZIP
      ,source_data.Bill_To_Address_Country AS Bill_To_Address_Country
      ,source_data.Ship_To_Address_Name_1 AS Ship_To_Address_Name_1
      ,source_data.Ship_To_Address_Name_2 AS Ship_To_Address_Name_2
      ,source_data.Ship_To_Address_Street_1 AS Ship_To_Address_Street_1
      ,source_data.Ship_To_Address_Street_2 AS Ship_To_Address_Street_2
      ,source_data.Ship_To_Address_City AS Ship_To_Address_City
      ,source_data.Ship_To_Address_State AS Ship_To_Address_State
      ,source_data.Ship_To_Address_ZIP AS Ship_To_Address_ZIP
      ,source_data.Ship_To_Address_Country AS Ship_To_Address_Country
      ,source_data.Customer_Contact AS Customer_Contact
      ,source_data.Customer_Contact_Phone AS Customer_Contact_Phone
      ,source_data.Customer_Tax_Code AS Customer_Tax_Code
      ,source_data.Customer_VAT_Registration_Number AS Customer_VAT_Registration_Number
      ,source_data.Order_Number AS Order_Number
      ,TRY_TO_NUMBER(source_data.Order_Line_Number,38,0) AS Order_Line_Number
      ,source_data.Customer_PO_Number AS Customer_PO_Number
      ,TRY_TO_NUMBER(source_data.Customer_PO_Line_Number,38,0) AS Customer_PO_Line_Number
      ,source_data.Material_number AS Material_number
      ,source_data.Part_Description AS Part_Description
      ,TRY_TO_NUMBER(source_data.Price,38,3) AS Price
      ,source_data.Currency AS Currency
      ,TRY_TO_NUMBER(source_data.Ship_Quantity,38,0) AS Ship_Quantity
      ,source_data.Shipment_Carrier AS Shipment_Carrier
      ,source_data.Shipment_Route AS Shipment_Route
      ,source_data.Order_Priority AS Order_Priority
      ,source_data.Storage_Location AS Storage_Location
      ,source_data.Ship_Date AS Ship_Date
      ,source_data.Header_Text AS Header_Text
      ,source_data.Line_Text AS Line_Text
      ,source_data.Commercial_Invoice_Number AS Commercial_Invoice_Number
      ,source_data.Customer_Part_Number AS Customer_Part_Number
      ,source_data.Country_of_Origin AS Country_of_Origin
      ,TRY_TO_NUMBER(source_data.Dual_Use,38,0) AS Dual_Use
      ,source_data.ECCN_Number AS ECCN_Number
      ,source_data.Shippers_HTS_Code AS Shippers_HTS_Code
      ,source_data.Receivers_HTS_Code AS Receivers_HTS_Code
      ,TRY_TO_NUMBER(source_data.Hazardous_Goods,38,0) AS Hazardous_Goods
      ,source_data.Chemical_Flag AS Chemical_Flag
      ,source_data.UN_Number AS UN_Number
      ,source_data.Incoterms AS Incoterms
      ,source_data.License_Number AS License_Number
      ,source_data.AES_Citation AS AES_Citation
      ,source_data.AES_Filing_Date AS AES_Filing_Date
      ,source_data.AES_Special_Instructions AS AES_Special_Instructions
      ,source_data.Trading_Partner AS Trading_Partner
      ,source_data.Load_Dt AS Load_Dt
      ,TRY_TO_NUMBER(source_data.Processed,38,0) AS Processed
      ,source_data.Process_Dt AS Process_Dt
      ,source_data.Error AS Error
      ,source_data.Error_Message AS Error_Message
      ,TRY_TO_NUMBER(source_data.Process_Id,38,0) AS Process_Id
      ,source_data.Delivery_Type AS Delivery_Type
      ,source_data.Receiving_Storage_Location AS Receiving_Storage_Location
      ,source_data.Schedule_Line_Number AS Schedule_Line_Number
      ,source_data._FileDate AS _FileDate
      ,'{{ invocation_id }}' AS AUDIT_LOG_ID
      ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
    FROM source_data
)
,type_data as 
(
    select
	   CAST(Document_Number AS VARCHAR(16777216)) AS Document_Number
      ,CAST(Line_Number AS NUMBER(38,0)) AS Line_Number
      ,CAST(Bill_To_Address_Name_1 AS VARCHAR(16777216)) AS  Bill_To_Address_Name_1
      ,CAST(Bill_To_Address_Name_2 AS VARCHAR(16777216)) AS  Bill_To_Address_Name_2
      ,CAST(Bill_To_Address_Street_1 AS VARCHAR(16777216)) AS Bill_To_Address_Street_1
      ,CAST(Bill_To_Address_Street_2 AS VARCHAR(16777216)) AS Bill_To_Address_Street_2
      ,CAST(Bill_To_Address_City AS VARCHAR(16777216)) AS Bill_To_Address_City
      ,CAST(Bill_To_Address_State AS VARCHAR(16777216)) AS Bill_To_Address_State
      ,CAST(Bill_To_Address_ZIP AS VARCHAR(16777216)) AS Bill_To_Address_ZIP
      ,CAST(Bill_To_Address_Country AS VARCHAR(16777216)) AS Bill_To_Address_Country
      ,CAST(Ship_To_Address_Name_1 AS VARCHAR(16777216)) AS Ship_To_Address_Name_1
      ,CAST(Ship_To_Address_Name_2 AS VARCHAR(16777216)) AS Ship_To_Address_Name_2
      ,CAST(Ship_To_Address_Street_1 AS VARCHAR(16777216)) AS Ship_To_Address_Street_1
      ,CAST(Ship_To_Address_Street_2 AS VARCHAR(16777216)) AS Ship_To_Address_Street_2
      ,CAST(Ship_To_Address_City AS VARCHAR(16777216)) AS Ship_To_Address_City
      ,CAST(Ship_To_Address_State AS VARCHAR(16777216)) AS Ship_To_Address_State
      ,CAST(Ship_To_Address_ZIP AS VARCHAR(16777216)) AS Ship_To_Address_ZIP
      ,CAST(Ship_To_Address_Country AS VARCHAR(16777216)) AS Ship_To_Address_Country
      ,CAST(Customer_Contact AS VARCHAR(16777216)) AS Customer_Contact
      ,CAST(Customer_Contact_Phone AS VARCHAR(16777216)) AS Customer_Contact_Phone
      ,CAST(Customer_Tax_Code AS VARCHAR(16777216)) AS Customer_Tax_Code
      ,CAST(Customer_VAT_Registration_Number AS VARCHAR(16777216)) AS Customer_VAT_Registration_Number
      ,CAST(Order_Number AS VARCHAR(16777216)) AS Order_Number
      ,CAST(Order_Line_Number AS NUMBER(38,0)) AS Order_Line_Number
      ,CAST(Customer_PO_Number AS VARCHAR(16777216)) AS Customer_PO_Number
      ,CAST(Customer_PO_Line_Number AS NUMBER(38,0)) AS Customer_PO_Line_Number
      ,CAST(Material_number AS VARCHAR(16777216)) AS Material_number
      ,CAST(Part_Description AS VARCHAR(16777216)) AS Part_Description
      ,CAST(Price AS NUMBER(38,3)) AS Price
      ,CAST(Currency AS VARCHAR(16777216)) AS Currency
      ,CAST(Ship_Quantity AS NUMBER(38,0)) AS Ship_Quantity
      ,CAST(Shipment_Carrier AS VARCHAR(16777216)) AS Shipment_Carrier
      ,CAST(Shipment_Route AS VARCHAR(16777216)) AS Shipment_Route
      ,CAST(Order_Priority AS VARCHAR(16777216)) AS Order_Priority
      ,CAST(Storage_Location AS VARCHAR(16777216)) AS Storage_Location
      ,CAST(Ship_Date  AS TIMESTAMP_NTZ(9)) AS Ship_Date
      ,CAST(Header_Text AS VARCHAR(16777216)) AS Header_Text
      ,CAST(Line_Text AS VARCHAR(16777216)) AS Line_Text
      ,CAST(Commercial_Invoice_Number AS VARCHAR(16777216)) AS Commercial_Invoice_Number
      ,CAST(Customer_Part_Number AS VARCHAR(16777216)) AS Customer_Part_Number
      ,CAST(Country_of_Origin AS VARCHAR(16777216)) AS Country_of_Origin
      ,CAST(Dual_Use AS NUMBER(38,0)) AS Dual_Use
      ,CAST(ECCN_Number AS VARCHAR(16777216)) AS ECCN_Number
      ,CAST(Shippers_HTS_Code AS VARCHAR(16777216)) AS Shippers_HTS_Code
      ,CAST(Receivers_HTS_Code AS VARCHAR(16777216)) AS Receivers_HTS_Code
      ,CAST(Hazardous_Goods AS NUMBER(38,0)) AS Hazardous_Goods
      ,CAST(Chemical_Flag AS VARCHAR(16777216)) AS Chemical_Flag
      ,CAST(UN_Number AS VARCHAR(16777216)) AS UN_Number
      ,CAST(Incoterms AS VARCHAR(16777216)) AS Incoterms
      ,CAST(License_Number AS VARCHAR(16777216)) AS License_Number
      ,CAST(AES_Citation AS VARCHAR(16777216)) AS AES_Citation
      ,CAST(AES_Filing_Date AS VARCHAR(16777216)) AS AES_Filing_Date
      ,CAST(AES_Special_Instructions AS VARCHAR(16777216)) AS AES_Special_Instructions
      ,CAST(Trading_Partner AS VARCHAR(16777216)) AS Trading_Partner
      ,CAST(Load_Dt AS TIMESTAMP_NTZ(9)) AS Load_Dt
      ,CAST(Processed AS NUMBER(38,0)) AS Processed
      ,CAST(Process_Dt AS TIMESTAMP_NTZ(9)) AS Process_Dt
      ,CAST(Error AS VARCHAR(16777216)) AS Error
      ,CAST(Error_Message AS VARCHAR(16777216)) AS Error_Message
      ,CAST(Process_Id AS NUMBER(38,0)) AS Process_Id
      ,CAST(Delivery_Type AS VARCHAR(16777216)) AS Delivery_Type
      ,CAST(Receiving_Storage_Location AS VARCHAR(16777216)) AS Receiving_Storage_Location
      ,CAST(Schedule_Line_Number AS VARCHAR(16777216)) AS Schedule_Line_Number
      ,CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
      ,CAST(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
      ,CAST(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data