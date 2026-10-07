{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='PAID_SERVICE_LEGACY_BAAN_BACKLOG'
) }}

with source_data as
(
    SELECT
        File_Creation_Date
        ,Backlog_Type
        ,Created_By
        ,Paid_Service
        ,TEA_Product_Type
        ,Booking_Date
        ,BAAN_Segment
        ,BU_Name
        ,SAP_BU_Code
        ,SO
        ,SAP_SO
        ,Baan_SO
        ,Invoice_To
        ,Ship_To_BP
        ,Customer_B_Code
        ,Backlog_Amount 
        ,Serial_Number
        ,Tool_Model
        ,Contract_Number
        ,Reference
        ,Related_Quote
        ,Customer
        ,Customer_Group
        ,Labor_Description
        ,Legacy_Order
        ,CRM_Work_Order
        ,Comment
        ,_FILENAME
		,_FILEDATE
		,_UPLOADDATE
    FROM {{ ref('ODS__FILE__PAID_SERVICE_LEGACY_BAAN_BACKLOG') }}
    where _UPLOADDATE = (select max(_UPLOADDATE) from {{ ref('ODS__FILE__PAID_SERVICE_LEGACY_BAAN_BACKLOG') }})
)

,transform_data as
(
    SELECT
        File_Creation_Date
        ,Backlog_Type
        ,Created_By
        ,Paid_Service
        ,TEA_Product_Type
        ,Booking_Date
        ,BAAN_Segment
        ,BU_Name
        ,SAP_BU_Code
        ,SO
        ,SAP_SO
        ,Baan_SO
        ,Invoice_To
        ,Ship_To_BP
        ,Customer_B_Code
        ,Backlog_Amount 
        ,Serial_Number
        ,Tool_Model
        ,Contract_Number
        ,Reference
        ,Related_Quote
        ,Customer
        ,Customer_Group
        ,Labor_Description
        ,Legacy_Order
        ,CRM_Work_Order
        ,Comment
        ,_FILENAME
		,_FILEDATE
		,_UPLOADDATE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH
    FROM source_data
)

,type_data as
(
    select
        CAST(File_Creation_Date AS DATE) AS File_Creation_Date
        ,CAST(Backlog_Type AS VARCHAR(16777216)) AS Backlog_Type
        ,CAST(Created_By AS VARCHAR(16777216)) AS Created_By
        ,CAST(Paid_Service AS VARCHAR(16777216)) AS Paid_Service
        ,CAST(TEA_Product_Type AS VARCHAR(16777216)) AS TEA_Product_Type
        ,CAST(Booking_Date AS DATE) AS Booking_Date
        ,CAST(BAAN_Segment AS VARCHAR(16777216)) AS BAAN_Segment
        ,CAST(BU_Name AS VARCHAR(16777216)) AS BU_Name
        ,CAST(SAP_BU_Code AS VARCHAR(16777216)) AS SAP_BU_Code
        ,CAST(SO AS VARCHAR(16777216)) AS SO
        ,CAST(SAP_SO AS VARCHAR(16777216)) AS SAP_SO
        ,CAST(Baan_SO AS VARCHAR(16777216)) AS Baan_SO
        ,CAST(Invoice_To AS VARCHAR(16777216)) AS Invoice_To
        ,CAST(Ship_To_BP AS VARCHAR(16777216)) AS Ship_To_BP
        ,CAST(Customer_B_Code AS VARCHAR(16777216)) AS Customer_B_Code
        ,CAST(Backlog_Amount  AS NUMBER(38,2)) AS  Backlog_Amount 
        ,CAST(Serial_Number AS VARCHAR(16777216)) AS Serial_Number
        ,CAST(Tool_Model AS VARCHAR(16777216)) AS Tool_Model
        ,CAST(Contract_Number AS VARCHAR(16777216)) AS Contract_Number
        ,CAST(Reference AS VARCHAR(16777216)) AS Reference
        ,CAST(Related_Quote AS VARCHAR(16777216)) AS Related_Quote
        ,CAST(Customer AS VARCHAR(16777216)) AS Customer
        ,CAST(Customer_Group AS VARCHAR(16777216)) AS Customer_Group
        ,CAST(Labor_Description AS VARCHAR(16777216)) AS Labor_Description
        ,CAST(Legacy_Order AS VARCHAR(16777216)) AS Legacy_Order
        ,CAST(CRM_Work_Order AS VARCHAR(16777216)) AS CRM_Work_Order
        ,CAST(Comment AS VARCHAR(16777216)) AS Comment
        ,CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME
        ,CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
        ,CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE
        ,CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID
        ,CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
    from transform_data
    )
select * from type_data