
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
    alias='THREEPL_TPL_SHIPMENT_LINE_DETAIL',
    unique_key = ['DOCUMENT_NUMBER',
    'LINE_NUMBER',
    'SEQUENCE_NUMBER']
) }}


with source_data as 
(
    SELECT 
         _FILENAME,
         _FILEDATE,
         JSONFIELD:"Document_Number"::STRING AS Document_Number, 
         JSONFIELD:"Line_Number"::NUMBER AS Line_Number, 
         JSONFIELD:"Sequence_Number"::NUMBER AS Sequence_Number, 
         JSONFIELD:"TPL_Order_Number"::STRING  AS TPL_Order_Number, 
         JSONFIELD:"Material_Number"::STRING  AS Material_Number, 
         JSONFIELD:"Quantity"::NUMBER AS Quantity, 
         JSONFIELD:"Serial_Number"::STRING AS Serial_Number, 
         JSONFIELD:"WMS_Batch_Number"::STRING  AS WMS_Batch_Number, 
         JSONFIELD:"Bill_of_Lading"::STRING AS Bill_of_Lading, 
         JSONFIELD:"Tracking_Number"::STRING AS Tracking_Number, 
         JSONFIELD:"Storage_Location"::STRING AS Storage_Location, 
         JSONFIELD:"Repair_Material_Number"::STRING AS Repair_Material_Number, 
         TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Last_Updated_Dt" ,'/Date()/')) AS Last_Updated_Dt, 
         JSONFIELD:"Processed"::SMALLINT AS Processed, 
         TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Process_Dt" ,'/Date()/')) AS Process_Dt, 
         JSONFIELD:"Error"::BOOLEAN AS Error,
         JSONFIELD:"Error_Message"::STRING AS Error_Message, 
         JSONFIELD:"Process_Id"::INT AS Process_Id
        FROM {{ source("THREEPL", "TPL_SHIPMENT_LINE_DETAIL") }} as s
        {% if is_tel_incremental() %} WHERE _FILEDATE > IFNULL((SELECT MAX(_FILEDATE) FROM {{ this }}),'1970-01-01') {% endif %}
		QUALIFY (ROW_NUMBER() OVER (PARTITION BY Document_Number,Line_Number,Sequence_Number ORDER BY _FILEDATE DESC )) = 1
)
,transform_data as
(
    SELECT 
        source_data._FILENAME  AS _FILENAME,
        source_data._FILEDATE  AS _FILEDATE, 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        source_data.Document_Number AS DOCUMENT_NUMBER,
        source_data.Line_Number AS LINE_NUMBER,
        source_data.Sequence_Number AS SEQUENCE_NUMBER,
        source_data.TPL_Order_Number AS TPL_ORDER_NUMBER,
        source_data.Material_Number AS MATERIAL_NUMBER,
        source_data.Quantity AS QUANTITY,
        source_data.Serial_Number AS SERIAL_NUMBER,
        source_data.WMS_Batch_Number AS WMS_BATCH_NUMBER,
        source_data.Bill_of_Lading AS BILL_OF_LADING,
        source_data.Tracking_Number AS TRACKING_NUMBER,
        source_data.Storage_Location AS STORAGE_LOCATION,
        source_data.Repair_Material_Number AS REPAIR_MATERIL_NUMBER,
        source_data.Last_Updated_Dt AS LAST_UPDATED_DT,
        source_data.Processed AS PROCESSED,
        source_data.Process_Dt AS PROCESS_DT,
        source_data.Error AS ERROR,
        source_data.Error_Message AS ERROR_MESSAGE,
        source_data.Process_Id AS PROCESS_ID
        FROM source_data
        )
,type_data as 
(
    select
         CAST(_FILENAME AS varchar(128)) AS _FILENAME,
         CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
         CAST(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
         CAST(_ROW_HASH as varchar(128)) as _ROW_HASH,
         CAST(DOCUMENT_NUMBER AS VARCHAR(16777216)) AS DOCUMENT_NUMBER,
         CAST(LINE_NUMBER AS NUMBER(38,0)) AS LINE_NUMBER,
         CAST(SEQUENCE_NUMBER AS NUMBER(38,0)) AS SEQUENCE_NUMBER,
         CAST(TPL_ORDER_NUMBER AS VARCHAR(16777216)) AS TPL_ORDER_NUMBER,
         CAST(MATERIAL_NUMBER AS VARCHAR(16777216)) AS MATERIAL_NUMBER,
         CAST(QUANTITY AS NUMBER(38,0)) AS QUANTITY,
         CAST(SERIAL_NUMBER AS VARCHAR(16777216)) AS SERIAL_NUMBER,
         CAST(WMS_BATCH_NUMBER AS VARCHAR(16777216)) AS WMS_BATCH_NUMBER,
         CAST(BILL_OF_LADING AS VARCHAR(16777216)) AS BILL_OF_LADING,
         CAST(TRACKING_NUMBER AS VARCHAR(16777216)) AS TRACKING_NUMBER,
         CAST(STORAGE_LOCATION AS VARCHAR(16777216)) AS STORAGE_LOCATION,
         CAST(REPAIR_MATERIL_NUMBER AS VARCHAR(16777216)) AS REPAIR_MATERIL_NUMBER,
         CAST(LAST_UPDATED_DT AS TIMESTAMP_NTZ(9)) AS LAST_UPDATED_DT,
         CAST(PROCESSED AS NUMBER(38,0)) AS PROCESSED,
         CAST(PROCESS_DT AS TIMESTAMP_NTZ(9)) AS PROCESS_DT,
         CAST(ERROR AS VARCHAR(16777216)) AS ERROR,
         CAST(ERROR_MESSAGE AS VARCHAR(16777216)) AS ERROR_MESSAGE,
         CAST(PROCESS_ID AS NUMBER(38,0)) AS PROCESS_ID
    from transform_data
    )
select * from type_data