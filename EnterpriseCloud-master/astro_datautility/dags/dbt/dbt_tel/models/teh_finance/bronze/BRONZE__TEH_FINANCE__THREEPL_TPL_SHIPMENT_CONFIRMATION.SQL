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
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='THREEPL_TPL_SHIPMENT_CONFIRMATION',
    unique_key = ['SHIPMENT_CONFIRMATION_ID',
    'DOCUMENT_NUMBER',
    'LINE_NUMBER']
) }}


with source_data as 
(
    SELECT JSONFIELD:"Shipment_Confirmation_Id"::NUMBER AS Shipment_Confirmation_Id, 
         JSONFIELD:"Document_Number"::NUMBER AS Document_Number, 
         JSONFIELD:"Line_Number"::NUMBER AS Line_Number, 
         JSONFIELD:"Material_Number"::STRING  AS Material_Number, 
         JSONFIELD:"WMS_Batch_Number"::STRING  AS WMS_Batch_Number, 
         JSONFIELD:"Picking_Quantity"::NUMBER AS Picking_Quantity, 
         JSONFIELD:"Serial_Number"::STRING AS Serial_Number, 
         JSONFIELD:"House_Airway_Bill_Number"::STRING  AS House_Airway_Bill_Number, 
         JSONFIELD:"Tracking_Number"::STRING AS Tracking_Number, 
         JSONFIELD:"Shipment_Carrier"::STRING AS Shipment_Carrier, 
         JSONFIELD:"TPL_Order_Number"::STRING AS TPL_Order_Number, 
         JSONFIELD:"TPL_Account_Number"::STRING AS TPL_Account_Number, 
         JSONFIELD:"TPL_Warehouse"::STRING  AS TPL_Warehouse, 
         JSONFIELD:"Storage_Location"::STRING  AS Storage_Location,
         JSONFIELD:"Goods_Issue_Date"::NUMBER AS Goods_Issue_Date,
         JSONFIELD:"Goods_Issue_Time"::NUMBER AS Goods_Issue_Time,
         JSONFIELD:"Repair_Material_Number"::STRING AS Repair_Material_Number,
         JSONFIELD:"Service_Level"::STRING AS Service_Level,
         JSONFIELD:"Processed"::INT AS Processed,
         TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Process_Dt" ,'/Date()/')) AS Process_Dt,
         JSONFIELD:"Process_Id"::INT AS Process_Id,
         JSONFIELD:"Error"::BOOLEAN AS Error,
         JSONFIELD:"Error_Message"::STRING AS Error_Message,
         _FileDate
    FROM {{ source("THREEPL", "TPL_SHIPMENT_CONFIRMATION") }} as s
    {% if is_tel_incremental() %} WHERE _FileDate > IFNULL((SELECT MAX(_FileDate) FROM {{ this }}),'1970-01-01') {% endif %}
	QUALIFY (ROW_NUMBER() OVER (PARTITION BY Shipment_Confirmation_Id,Document_Number,Line_Number ORDER BY _Filedate DESC )) = 1
)
,transform_data as
(
    SELECT 
	   TRY_TO_NUMBER(Shipment_Confirmation_Id,38,0) AS Shipment_Confirmation_Id
      ,TRY_TO_NUMBER(Document_Number,38,0) AS Document_Number
      ,TRY_TO_NUMBER(Line_Number,38,0) AS Line_Number
      ,Material_Number
      ,WMS_Batch_Number
      ,TRY_TO_NUMBER(Picking_Quantity,38,0) AS Picking_Quantity
      ,Serial_Number
      ,House_Airway_Bill_Number
      ,Tracking_Number
      ,Shipment_Carrier
      ,TPL_Order_Number
      ,TPL_Account_Number
      ,TPL_Warehouse
      ,Storage_Location
      ,TRY_TO_NUMBER(Goods_Issue_Date,38,0) AS Goods_Issue_Date
      ,TRY_TO_NUMBER(Goods_Issue_Time,38,0) AS Goods_Issue_Time
      ,Repair_Material_Number
      ,Service_Level
      ,TRY_TO_NUMBER(Processed,38,0) AS Processed
      ,Process_Dt
      ,TRY_TO_NUMBER(Process_ID,38,0) AS Process_ID
      ,Error
      ,Error_Message
      ,_FileDate
      ,'{{ invocation_id }}' AS AUDIT_LOG_ID
      ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
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

