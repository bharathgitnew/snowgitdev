{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='TPL_SHIP_REQUEST',
    unique_key = ['DOCUMENT_NUMBER',
    'LINE_NUMBER']
) }}

with source_data as 
(
    SELECT
    Document_Number,
    Line_Number,
    Bill_To_Address_Name_1,
    Bill_To_Address_Name_2,
    Bill_To_Address_Street_1,
    Bill_To_Address_Street_2,
    Bill_To_Address_City,
    Bill_To_Address_State,
    Bill_To_Address_ZIP,
    Bill_To_Address_Country,
    Ship_To_Address_Name_1,
    Ship_To_Address_Name_2,
    Ship_To_Address_Street_1,
    Ship_To_Address_Street_2,
    Ship_To_Address_City,
    Ship_To_Address_State,
    Ship_To_Address_ZIP,
    Ship_To_Address_Country,
    Customer_Contact,
    Customer_Contact_Phone,
    Customer_Tax_Code,
    Customer_VAT_Registration_Number,
    Order_Number,
    Order_Line_Number,
    Customer_PO_Number,
    Customer_PO_Line_Number,
    Material_number,
    Part_Description,
    Price,
    Currency,
    Ship_Quantity,
    Shipment_Carrier,
    Shipment_Route,
    Order_Priority,
    Storage_Location,
    Ship_Date,
    Header_Text,
    Line_Text,
    Commercial_Invoice_Number,
    Customer_Part_Number,
    Country_of_Origin,
    Dual_Use,
    ECCN_Number,
    Shippers_HTS_Code,
    Receivers_HTS_Code,
    Hazardous_Goods,
    Chemical_Flag,
    UN_Number,
    Incoterms,
    License_Number,
    AES_Citation,
    AES_Filing_Date,
    AES_Special_Instructions,
    Trading_Partner,
    Load_Dt,
    Processed,
    Process_Dt,
    Error,
    Error_Message,
    Process_Id,
    Delivery_Type,
    Receiving_Storage_Location,
    Schedule_Line_Number,
    _FileDate
    FROM {{ ref('ODS__THREEPL__TPL_SHIP_REQUEST') }}  
    {% if is_incremental() %} WHERE _FileDate > IFNULL((SELECT MAX(_FileDate) FROM {{ this }}),'1970-01-01') {% endif %}
	QUALIFY (ROW_NUMBER() OVER (PARTITION BY Document_Number,Line_Number ORDER BY _Filedate DESC )) = 1
)
,transform_data as
(
    SELECT
    Document_Number,
    Line_Number,
    Bill_To_Address_Name_1,
    Bill_To_Address_Name_2,
    Bill_To_Address_Street_1,
    Bill_To_Address_Street_2,
    Bill_To_Address_City,
    Bill_To_Address_State,
    Bill_To_Address_ZIP,
    Bill_To_Address_Country,
    Ship_To_Address_Name_1,
    Ship_To_Address_Name_2,
    Ship_To_Address_Street_1,
    Ship_To_Address_Street_2,
    Ship_To_Address_City,
    Ship_To_Address_State,
    Ship_To_Address_ZIP,
    Ship_To_Address_Country,
    Customer_Contact,
    Customer_Contact_Phone,
    Customer_Tax_Code,
    Customer_VAT_Registration_Number,
    Order_Number,
    Order_Line_Number,
    Customer_PO_Number,
    Customer_PO_Line_Number,
    Material_number,
    Part_Description,
    Price,
    Currency,
    Ship_Quantity,
    Shipment_Carrier,
    Shipment_Route,
    Order_Priority,
    Storage_Location,
    Ship_Date,
    Header_Text,
    Line_Text,
    Commercial_Invoice_Number,
    Customer_Part_Number,
    Country_of_Origin,
    Dual_Use,
    ECCN_Number,
    Shippers_HTS_Code,
    Receivers_HTS_Code,
    Hazardous_Goods,
    Chemical_Flag,
    UN_Number,
    Incoterms,
    License_Number,
    AES_Citation,
    AES_Filing_Date,
    AES_Special_Instructions,
    Trading_Partner,
    Load_Dt,
    Processed,
    Process_Dt,
    Error,
    Error_Message,
    Process_Id,
    Delivery_Type,
    Receiving_Storage_Location,
    Schedule_Line_Number,
    _FileDate,
    '{{ invocation_id }}' AS AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH
    FROM source_data
)

,type_data as 
(
    SELECT
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
    FROM transform_data
    )

SELECT * FROM type_data