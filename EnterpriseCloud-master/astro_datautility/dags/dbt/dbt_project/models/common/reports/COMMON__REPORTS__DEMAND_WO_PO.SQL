{{ config(
        materialized='incremental',
        incremental_strategy='insert_overwrite',
        alias='DEMAND_WO_PO',
        transient=false
) }}

With Demand as (
    Select distinct
        concat( VBAK_SALES_DOCUMENT, '|', SALES_DOCUMENT_ITEM_POSNR) as Doc_Line_ID
        ,VBAK_SALES_DOCUMENT as Doc_Header
        ,SALES_DOCUMENT_ITEM_POSNR as Doc_Line
        ,to_date(DOCUMENT_DATE, 'YYYYMMDD') as Doc_Date
        ,MATERIAL_NUMBER as Material 
        ,VBAK_SALES_DOCUMENT_TYPE as Doc_Type
        ,STORAGE_LOCATION_VBAP as SLOC
        ,VBAK_OVERALL_PROCESSING_STATUS_OF_DOCUMENT as Doc_Status
        ,NET_VALUE_OF_THE_ORDER_ITEM_IN_DOCUMENT_CURRENCY as Amount 
        ,TARGET_QUANTITY_IN_SALES_UNITS as QTY
        ,  'SO' as Record_Type
    From {{ ref('COMMON__SAPH__SALES_ORDER_DELIVERY_LINE') }}
    UNION ALL
    Select distinct
        concat( EKPO_PURCHASING_DOCUMENT_NUMBER, '|', ITEM_NUMBER_OF_PURCHASING_DOCUMENT_EBELP) as Doc_Line_ID
        ,EKPO_PURCHASING_DOCUMENT_NUMBER as Doc_Header
        ,ITEM_NUMBER_OF_PURCHASING_DOCUMENT_EBELP as Doc_Line
        ,try_to_date(EKKO_DELIVERY_CREATE_DATE, 'YYYYMMDD') as Doc_Date
        ,MATERIAL_NUMBER_MATNR as  Material 
        ,PURCHASING_DOCUMENT_TYPE as Doc_Type
        ,EKPO_STORAGE_LOCATION as SLOC 
        ,STATUS_OF_PURCHASING_DOCUMENT as Doc_Status 
        ,NET_PRICE_IN_PURCHASING_DOCUMENT as Amount
        ,PURCHASE_ORDER_QUANTITY as QTY
        ,  'PO' as Record_Type
    From {{ ref('COMMON__SAPH__PURCHASE_ORDER_DELIVERY_LINE') }}
    UNION ALL
    Select 
         '' as Doc_Line_ID
        ,'' as Doc_Header
        ,'' as Doc_Line 
        ,'1900-01-01' as Doc_Date
        ,ITEMID as  Material
        ,'INV' as Doc_Type
        ,WAREHOUSEID as SLOC 
        ,INVENTORYSTATUS as Doc_Status 
        ,NULL as Amount
        ,INVENTORYQUANTITY as QTY
        ,  'INV' as Record_Type
    From {{ ref('COMMON__PROPHET__INVENTORY_LIVE') }}
        ),
MAT as (
    Select distinct 
        MATERIAL_DESCRIPTION, 
        MARA_MATERIAL_NUMBER  
    From {{ ref('COMMON__SAPH__MATERIAL_PLANT_MASTER') }}
        ),
SOURCE_DATA as (
Select 
    DEM.DOC_LINE_ID        
    ,DEM.DOC_HEADER         
    ,DEM.DOC_LINE           
    ,DEM.DOC_DATE           
    ,DEM.MATERIAL           
    ,DEM.DOC_TYPE           
    ,DEM.SLOC               
    ,DEM.DOC_STATUS         
    ,DEM.AMOUNT             
    ,DEM.QTY                
    ,DEM.RECORD_TYPE  
    ,MAT.MATERIAL_DESCRIPTION
    ,MAT.MARA_MATERIAL_NUMBER
    ,CASE when DEM.Record_Type = 'SO' then DEM.Doc_Date end as Sales_Date
    ,CASE when DEM.Record_Type = 'PO' then DEM.Doc_Date end as Purchase_Date
    ,CASE when DEM.Record_Type = 'SO' then DEM.Doc_Type end as Sales_Doc_Type
    ,CASE when DEM.Record_Type = 'PO' then DEM.Doc_Type end as Purchase_Doc_Type
from DEMAND AS DEM 
Left Join MAT mat 
on  MAT.MARA_MATERIAL_NUMBER = DEM.Material
),
TRANSFORM_DATA as (
SELECT
    DOC_LINE_ID        
    ,DOC_HEADER         
    ,DOC_LINE           
    ,DOC_DATE           
    ,MATERIAL           
    ,DOC_TYPE           
    ,SLOC               
    ,DOC_STATUS         
    ,AMOUNT             
    ,QTY                
    ,RECORD_TYPE        
    ,MATERIAL_DESCRIPTION
    ,MARA_MATERIAL_NUMBER
    ,SALES_DATE         
    ,PURCHASE_DATE      
    ,SALES_DOC_TYPE     
    ,PURCHASE_DOC_TYPE  
    ,'{{ invocation_id }}' AS AUDIT_LOG_ID
    ,SHA2('hash_me') AS _ROW_HASH -- Adds column to table on full refresh.
FROM SOURCE_DATA
), 
TYPE_DATA as (
SELECT
    CAST(DOC_LINE_ID AS VARCHAR(16777216)) AS DOC_LINE_ID
    ,CAST(DOC_HEADER AS VARCHAR(16777216)) AS DOC_HEADER         
    ,CAST(DOC_LINE AS VARCHAR(16777216)) AS DOC_LINE           
    ,CAST(DOC_DATE AS VARCHAR(16777216)) AS DOC_DATE           
    ,CAST(MATERIAL AS VARCHAR(16777216)) AS MATERIAL          
    ,CAST(DOC_TYPE AS VARCHAR(16777216)) AS DOC_TYPE           
    ,CAST(SLOC AS VARCHAR(16777216)) AS SLOC               
    ,CAST(DOC_STATUS AS VARCHAR(16777216)) AS DOC_STATUS         
    ,CAST(AMOUNT AS NUMBER(38,2)) AS AMOUNT             
    ,CAST(QTY AS NUMBER(38,0)) AS QTY                
    ,CAST(RECORD_TYPE AS VARCHAR(16777216)) AS RECORD_TYPE        
    ,CAST(MATERIAL_DESCRIPTION AS VARCHAR(16777216)) AS MATERIAL_DESCRIPTION
    ,CAST(MARA_MATERIAL_NUMBER AS VARCHAR(16777216)) AS MARA_MATERIAL_NUMBER
    ,CAST(SALES_DATE AS TIMESTAMP_LTZ(9)) AS SALES_DATE         
    ,CAST(PURCHASE_DATE AS TIMESTAMP_LTZ(9)) AS PURCHASE_DATE      
    ,CAST(SALES_DOC_TYPE AS VARCHAR(16777216)) AS SALES_DOC_TYPE     
    ,CAST(PURCHASE_DOC_TYPE AS VARCHAR(16777216)) AS PURCHASE_DOC_TYPE  
    ,CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID
    ,CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA