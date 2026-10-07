{{ config(
        materialized='incremental',
        incremental_strategy='insert_overwrite',
        alias='DELIVERY_ORDER_MASTER_REPORT',
        transient=false,
        enabled=true
) }}

with cost_center as (
select
    COST_CENTER_CODE,
    SEGMENT_CODE as SECURITY_SEGMENT,
    DEPARTMENT_CODE as SECURITY_DEPARTMENT,
    OFFICE_CODE as SECURITY_OFFICE
from {{ ref('ODS__FILE__COST_CENTER') }}),

profit_center as (
select
    PROFIT_CENTER_CODE,
    PROFIT_CENTER_NAME,
    SEGMENT_CODE,
    SEGMENT,
    DEPARTMENT_CODE,
    DEPARTMENT,
    OFFICE_CODE,
    OFFICE
from {{ ref('ODS__FILE__PROFIT_CENTER') }}),

storage_location_description_data as (
select
    LGORT AS STORAGE_LOC_NO,
    LGOBE as DESCRIPTION_OF_STORAGE_LOCATION
from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU080_T001L') }}),

source_data as (
    Select
        'Sales' as Header_Type
        ,VBAK_SALES_DOCUMENT as Doc_Header
        ,SALES_DOCUMENT_ITEM_POSNR as Header_Doc_Line
        ,LIPS_DELIVERY as Delivery_Header
        ,DELIVERY_ITEM_POSNR as Delivery_Line
        ,concat(LIPS_DELIVERY ,'|' , DELIVERY_ITEM_POSNR) as Delivery_ID
        ,MATERIAL_NUMBER as Material_Number
        ,MATERIAL_DESCRIPTION
        ,VBAP_ORIGINATING_DOCUMENT as Originating_Doc_Header
        ,VBAP_ORIGINATING_ITEM as Originating_Doc_Line
        ,VBAP_DOCUMENT_NUMBER_OF_THE_REFERENCE_DOCUMENT as Refernce_Doc_Header
        ,VBAP_ITEM_NUMBER_OF_THE_REFERENCE_ITEM as Reference_Doc_Line
        ,to_date(LIKP_SHIP_DATE) as Ship_Date
        ,STORAGE_LOCATION_LIPS as Storage_Loc
        ,storage_location_description_data.DESCRIPTION_OF_STORAGE_LOCATION as  Storage_Loc_Name
        ,PLANT_LIPS as Plant
        ,try_to_date(REQUESTED_DELIVERY_DATE,'YYYYMMDD')           as Requested_Delivery_Date
        ,try_to_date(DELIVERY_DATE_LFDAT,'YYYYMMDD')               as Delivery_Date
        ,try_to_date(DELIVERY_DATE_ZZDDZZ,'YYYYMMDD')              as Delivery_Date_Z
        ,try_to_date(CONFIRMED_WAREHOUSE_DELIVERY_DATE,'YYYYMMDD') as Conf_WH_Delivery_Date
        ,try_to_date(SCHEDULED_WAREHOUSE_DELIVERY_DATE,'YYYYMMDD') as Sched_WH_Delivery_Date
        ,try_to_date(PLANNED_DELIVERY_DATE_TO_RECEIVER,'YYYYMMDD') as Planned_Delivery_Date
        ,PURCHASE_ORDER_QUANTITY          as Purchase_Order_Qty
        ,ACTUAL_QUANTITY_DELIVERED        as Actual_Del_Qty
        ,VBAK_DELAY_STATUS              as Delay_Status
        ,VBAK_DELIVERY_STATUS           as Delivery_Status
        ,VBAK_OVERALL_GOODS_MOVEMENT_STATUS as Movement_Status
        ,PLANNED_GOODS_MOVEMENT_DATE as Planned_Goods_Move_Date
        ,VBAP_PROFIT_CENTER as PROFIT_CENTER
        ,VBAP_COST_CENTER as COST_CENTER
        ,'<ALL>' as SECURITY_SEGMENT
        ,'<ALL>' as SECURITY_DEPARTMENT
        ,'<ALL>' as SECURITY_OFFICE
    From {{ ref('COMMON__SAPH__SALES_ORDER_DELIVERY_LINE') }} a
    Left Join storage_location_description_data
        on storage_location_description_data.STORAGE_LOC_NO=a.STORAGE_LOCATION_LIPS
    Left Join (Select Distinct MATERIAL_DESCRIPTION, MARA_MATERIAL_NUMBER from {{ ref('COMMON__SAPH__MATERIAL_STORAGE_LOCATION_MASTER') }}) mat
        on a.MATERIAL_NUMBER = mat.MARA_MATERIAL_NUMBER
    left outer join cost_center
        on COST_CENTER=cost_center.COST_CENTER_CODE
    left outer join profit_center
        on PROFIT_CENTER=profit_center.PROFIT_CENTER_CODE
        UNION ALL
    Select
        'Purchase' as Header_Type
        ,EKKO_PURCHASING_DOCUMENT_NUMBER as Doc_Header
        ,ITEM_NUMBER_OF_PURCHASING_DOCUMENT_EBELP as Header_Doc_Line
        ,LIKP_Delivery as Delivery_Header
        ,DELIVERY_ITEM_POSNR as Delivery_Line
        ,concat(LIKP_Delivery ,'|' , DELIVERY_ITEM_POSNR) as Delivery_ID
        ,MATERIAL_NUMBER_MATNR as Material_Number
        ,MATERIAL_DESCRIPTION
        ,'' as Originating_Doc_Header
        ,'' as Originating_Doc_Line
        ,REFERENCE_DOCUMENT_NUMBER_FOR_PO_TRACEABILITY as Refernce_Doc_Header
        ,REFERENCE_ITEM_NUMBER_FOR_PO_TRACEABILITY as Reference_Doc_Line
        ,to_date(SHIP_DATE) as Ship_Date
        ,a.EKPO_STORAGE_LOCATION as Storage_Loc
        ,storage_location_description_data.DESCRIPTION_OF_STORAGE_LOCATION as  Storage_Loc_Name
        ,a.EKPO_Plant
        ,try_to_date(PLANNED_GOODS_MOVEMENT_DATE)        as Requested_Delivery_Date
        ,try_to_date(DELIVERY_DATE_LFDAT)               as Delivery_Date
        ,try_to_date(DELIVERY_DATE_ZZDDZZ)              as Delivery_Date_Z
        ,try_to_date(CONFIRMED_WAREHOUSE_DELIVERY_DATE) as Conf_WH_Delivery_Date
        ,'0'                                       as SCHED_WH_DELIVERY_DATE
        ,try_to_date(PLANNED_DELIVERY_DATE_TO_RECEIVER ) as Planned_Delivery_Date
        ,PURCHASE_ORDER_QUANTITY          as Purchase_Order_Qty
        ,ACTUAL_QUANTITY_DELIVERED        as Actual_Del_Qty
        ,'N/A'                          as Delay_Status
        ,DELIVERY_CONFIRMATION_STATUS   as Delivery_Status
        ,OVERALL_GOODS_MOVEMENT_STATUS as Movement_Status
        ,PLANNED_GOODS_MOVEMENT_DATE as Planned_Goods_Move_Date
        ,EKPO_PROFIT_CENTER as PROFIT_CENTER
        ,LIPS_COST_CENTER as COST_CENTER
        ,'<ALL>' as SECURITY_SEGMENT
        ,'<ALL>' as SECURITY_DEPARTMENT
        ,'<ALL>' as SECURITY_OFFICE
    From {{ ref('COMMON__SAPH__PURCHASE_ORDER_DELIVERY_LINE') }} a
    Left Join storage_location_description_data
        on storage_location_description_data.STORAGE_LOC_NO=a.EKPO_STORAGE_LOCATION
    Left Join (Select Distinct MATERIAL_DESCRIPTION, MARA_MATERIAL_NUMBER from {{ ref('COMMON__SAPH__MATERIAL_STORAGE_LOCATION_MASTER') }}) mat
        on a.MATERIAL_NUMBER = mat.MARA_MATERIAL_NUMBER
    left outer join cost_center
        on COST_CENTER=cost_center.COST_CENTER_CODE
    left outer join profit_center
        on PROFIT_CENTER=profit_center.PROFIT_CENTER_CODE
),

transform_data as (
    select
        HEADER_TYPE,
        DOC_HEADER,
        HEADER_DOC_LINE,
        DELIVERY_HEADER,
        DELIVERY_LINE,
        DELIVERY_ID,
        MATERIAL_NUMBER,
        MATERIAL_DESCRIPTION,
        ORIGINATING_DOC_HEADER,
        ORIGINATING_DOC_LINE,
        REFERNCE_DOC_HEADER,
        REFERENCE_DOC_LINE,
        SHIP_DATE,
        STORAGE_LOC,
        STORAGE_LOC_NAME,
        PLANT,
        REQUESTED_DELIVERY_DATE,
        DELIVERY_DATE,
        DELIVERY_DATE_Z,
        CONF_WH_DELIVERY_DATE,
        SCHED_WH_DELIVERY_DATE,
        PLANNED_DELIVERY_DATE,
        PURCHASE_ORDER_QTY,
        ACTUAL_DEL_QTY,
        DELAY_STATUS,
        DELIVERY_STATUS,
        MOVEMENT_STATUS,
        PLANNED_GOODS_MOVE_DATE,
        PROFIT_CENTER,
        COST_CENTER,
        SECURITY_SEGMENT,
        SECURITY_DEPARTMENT,
        SECURITY_OFFICE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID
    from source_data
),

type_data as (
    select
        CAST(HEADER_TYPE AS VARCHAR(16777216)) AS HEADER_TYPE,
        CAST(DOC_HEADER AS VARCHAR(16777216)) AS DOC_HEADER,
        CAST(HEADER_DOC_LINE AS VARCHAR(16777216)) AS HEADER_DOC_LINE,
        CAST(DELIVERY_HEADER AS VARCHAR(16777216)) AS DELIVERY_HEADER,
        CAST(DELIVERY_LINE AS VARCHAR(16777216)) AS DELIVERY_LINE,
        CAST(DELIVERY_ID AS VARCHAR(16777216)) AS DELIVERY_ID,
        CAST(MATERIAL_NUMBER AS VARCHAR(16777216)) AS MATERIAL_NUMBER,
        CAST(MATERIAL_DESCRIPTION AS VARCHAR(16777216)) AS MATERIAL_DESCRIPTION,
        CAST(ORIGINATING_DOC_HEADER AS VARCHAR(16777216)) AS ORIGINATING_DOC_HEADER,
        CAST(ORIGINATING_DOC_LINE AS VARCHAR(16777216)) AS ORIGINATING_DOC_LINE,
        CAST(REFERNCE_DOC_HEADER AS VARCHAR(16777216)) AS REFERNCE_DOC_HEADER,
        CAST(REFERENCE_DOC_LINE AS VARCHAR(16777216)) AS REFERENCE_DOC_LINE,
        CAST(SHIP_DATE AS DATE) AS SHIP_DATE,
        CAST(STORAGE_LOC AS VARCHAR(16777216)) AS STORAGE_LOC,
        CAST(STORAGE_LOC_NAME AS VARCHAR(16777216)) AS STORAGE_LOC_NAME,
        CAST(PLANT AS VARCHAR(16777216)) AS PLANT,
        CAST(REQUESTED_DELIVERY_DATE AS DATE) AS REQUESTED_DELIVERY_DATE,
        CAST(DELIVERY_DATE AS DATE) AS DELIVERY_DATE,
        CAST(DELIVERY_DATE_Z AS DATE) AS DELIVERY_DATE_Z,
        CAST(CONF_WH_DELIVERY_DATE AS DATE) AS CONF_WH_DELIVERY_DATE,
        CAST(SCHED_WH_DELIVERY_DATE AS DATE) AS SCHED_WH_DELIVERY_DATE,
        CAST(PLANNED_DELIVERY_DATE AS DATE) AS PLANNED_DELIVERY_DATE,
        CAST(PURCHASE_ORDER_QTY AS NUMBER(38,10)) AS PURCHASE_ORDER_QTY,
        CAST(ACTUAL_DEL_QTY AS NUMBER(38,10)) AS ACTUAL_DEL_QTY,
        CAST(DELAY_STATUS AS VARCHAR(16777216)) AS DELAY_STATUS,
        CAST(DELIVERY_STATUS AS VARCHAR(16777216)) AS DELIVERY_STATUS,
        CAST(MOVEMENT_STATUS AS VARCHAR(16777216)) AS MOVEMENT_STATUS,
        CAST(PLANNED_GOODS_MOVE_DATE AS DATE) AS PLANNED_GOODS_MOVE_DATE,
		CAST(PROFIT_CENTER AS VARCHAR(16777216)) AS PROFIT_CENTER,
		CAST(COST_CENTER AS VARCHAR(16777216)) AS COST_CENTER,
        cast(SECURITY_SEGMENT as VARCHAR(16777216)) as SECURITY_SEGMENT,
        cast(SECURITY_DEPARTMENT as VARCHAR(16777216)) as SECURITY_DEPARTMENT,
        cast(SECURITY_OFFICE as VARCHAR(16777216)) as SECURITY_OFFICE,
		CAST(AUDIT_LOG_ID as VARCHAR(128)) as AUDIT_LOG_ID
    from transform_data
)

select * from type_data