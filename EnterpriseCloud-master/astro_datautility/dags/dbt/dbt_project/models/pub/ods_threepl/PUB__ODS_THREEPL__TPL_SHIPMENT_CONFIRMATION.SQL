/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.41.23"
*************/

{{ config(
      materialized='view',
      alias='TPL_SHIPMENT_CONFIRMATION',
      transient=false
) }}

with source_data as (
    SELECT
       Shipment_Confirmation_Id
      ,Document_Number
      ,Line_Number
      ,Material_Number
      ,WMS_Batch_Number
      ,Picking_Quantity
      ,Serial_Number
      ,House_Airway_Bill_Number
      ,Tracking_Number
      ,Shipment_Carrier
      ,TPL_Order_Number
      ,TPL_Account_Number
      ,TPL_Warehouse
      ,Storage_Location
      ,Goods_Issue_Date
      ,Goods_Issue_Time
      ,Repair_Material_Number
      ,Service_Level
      ,Processed
      ,Process_Dt
      ,Process_ID
      ,Error
      ,Error_Message
    from {{ ref('ODS__THREEPL__TPL_SHIPMENT_CONFIRMATION') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data