/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.41.23"
*************/

{{ config(
      materialized='view',
      alias='TPL_SHIP_REQUEST',
      transient=false
) }}

with source_data as (
    SELECT
       Document_Number
      ,Line_Number
      ,Bill_To_Address_Name_1
      ,Bill_To_Address_Name_2
      ,Bill_To_Address_Street_1
      ,Bill_To_Address_Street_2
      ,Bill_To_Address_City
      ,Bill_To_Address_State
      ,Bill_To_Address_ZIP
      ,Bill_To_Address_Country
      ,Ship_To_Address_Name_1
      ,Ship_To_Address_Name_2
      ,Ship_To_Address_Street_1
      ,Ship_To_Address_Street_2
      ,Ship_To_Address_City
      ,Ship_To_Address_State
      ,Ship_To_Address_ZIP
      ,Ship_To_Address_Country
      ,Customer_Contact
      ,Customer_Contact_Phone
      ,Customer_Tax_Code
      ,Customer_VAT_Registration_Number
      ,Order_Number
      ,Order_Line_Number
      ,Customer_PO_Number
      ,Customer_PO_Line_Number
      ,Material_number
      ,Part_Description
      ,Price
      ,Currency
      ,Ship_Quantity
      ,Shipment_Carrier
      ,Shipment_Route
      ,Order_Priority
      ,Storage_Location
      ,Ship_Date
      ,Header_Text
      ,Line_Text
      ,Commercial_Invoice_Number
      ,Customer_Part_Number
      ,Country_of_Origin
      ,Dual_Use
      ,ECCN_Number
      ,Shippers_HTS_Code
      ,Receivers_HTS_Code
      ,Hazardous_Goods
      ,Chemical_Flag
      ,UN_Number
      ,Incoterms
      ,License_Number
      ,AES_Citation
      ,AES_Filing_Date
      ,AES_Special_Instructions
      ,Trading_Partner
      ,Load_Dt
      ,Processed
      ,Process_Dt
      ,Error
      ,Error_Message
      ,Process_Id
      ,Delivery_Type
      ,Receiving_Storage_Location
      ,Schedule_Line_Number
    from {{ ref('ODS__THREEPL__TPL_SHIP_REQUEST') }}
),

transform_data AS
(
    select * from source_data
)
    select * from transform_data