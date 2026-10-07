{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='TPL_SHIPMENT_CONFIRMATION',
    unique_key = ['SHIPMENT_CONFIRMATION_ID',
    'DOCUMENT_NUMBER',
    'LINE_NUMBER']
) }}

with source_data as 
(
    SELECT
    Shipment_Confirmation_Id,
    Document_Number,
    Line_Number,
    Material_Number,
    WMS_Batch_Number,
    Picking_Quantity,
    Serial_Number,
    House_Airway_Bill_Number,
    Tracking_Number,
    Shipment_Carrier,
    TPL_Order_Number,
    TPL_Account_Number,
    TPL_Warehouse,
    Storage_Location,
    Goods_Issue_Date,
    Goods_Issue_Time,
    Repair_Material_Number,
    Service_Level,
    Processed,
    Process_Dt,
    Process_Id,
    Error,
    Error_Message,
    _FileDate
    FROM {{ ref('ODS__THREEPL__TPL_SHIPMENT_CONFIRMATION') }}
    {% if is_incremental() %} WHERE _FileDate > IFNULL((SELECT MAX(_FileDate) FROM {{ this }}),'1970-01-01') {% endif %}
	QUALIFY (ROW_NUMBER() OVER (PARTITION BY Shipment_Confirmation_Id,Document_Number,Line_Number ORDER BY _Filedate DESC )) = 1
)

,transform_data as
(
    SELECT 
    Shipment_Confirmation_Id,
    Document_Number,
    Line_Number,
    Material_Number,
    WMS_Batch_Number,
    Picking_Quantity,
    Serial_Number,
    House_Airway_Bill_Number,
    Tracking_Number,
    Shipment_Carrier,
    TPL_Order_Number,
    TPL_Account_Number,
    TPL_Warehouse,
    Storage_Location,
    Goods_Issue_Date,
    Goods_Issue_Time,
    Repair_Material_Number,
    Service_Level,
    Processed,
    Process_Dt,
    Process_Id,
    Error,
    Error_Message,
    _FileDate,
    '{{ invocation_id }}' AS AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
    FROM source_data
)

,type_data as 
(
    select
	   CAST(Shipment_Confirmation_Id AS NUMBER(38,0)) AS  Shipment_Confirmation_Id
      ,CAST(Document_Number AS NUMBER(38,0)) AS  Document_Number
      ,CAST(Line_Number AS NUMBER(38,0)) AS  Line_Number
      ,CAST(Material_Number AS VARCHAR(16777216)) AS Material_Number
      ,CAST(WMS_Batch_Number AS VARCHAR(16777216)) AS WMS_Batch_Number
      ,CAST(Picking_Quantity AS NUMBER(38,0)) AS  Picking_Quantity
      ,CAST(Serial_Number AS VARCHAR(16777216)) AS Serial_Number
      ,CAST(House_Airway_Bill_Number AS VARCHAR(16777216)) AS House_Airway_Bill_Number
      ,CAST(Tracking_Number AS VARCHAR(16777216)) AS Tracking_Number
      ,CAST(Shipment_Carrier AS VARCHAR(16777216)) AS Shipment_Carrier
      ,CAST(TPL_Order_Number AS VARCHAR(16777216)) AS TPL_Order_Number
      ,CAST(TPL_Account_Number AS VARCHAR(16777216)) AS TPL_Account_Number
      ,CAST(TPL_Warehouse AS VARCHAR(16777216)) AS TPL_Warehouse
      ,CAST(Storage_Location AS VARCHAR(16777216)) AS Storage_Location
      ,CAST(Goods_Issue_Date AS NUMBER(38,0)) AS  Goods_Issue_Date
      ,CAST(Goods_Issue_Time AS NUMBER(38,0)) AS  Goods_Issue_Time
      ,CAST(Repair_Material_Number AS VARCHAR(16777216)) AS Repair_Material_Number
      ,CAST(Service_Level AS VARCHAR(16777216)) AS Service_Level
      ,CAST(Processed AS NUMBER(38,0)) AS  Processed
      ,CAST(Process_Dt AS TIMESTAMP_NTZ(9)) AS Process_Dt
      ,CAST(Process_ID AS NUMBER(38,0)) AS  Process_ID
      ,CAST(Error AS VARCHAR(16777216)) AS Error
      ,CAST(Error_Message AS VARCHAR(16777216)) AS Error_Message
      ,CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
      ,CAST(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
      ,CAST(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
)
select * from type_data