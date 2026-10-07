{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='TPL_SHIPMENT_LINE_DETAIL',
    unique_key = ['DOCUMENT_NUMBER',
    'LINE_NUMBER',
    'SEQUENCE_NUMBER']
) }}

with source_data as 
(
    SELECT
    Document_Number,
    Line_Number,
    Sequence_Number,
    TPL_Order_Number,
    Material_Number,
    Quantity,
    Serial_Number,
    WMS_Batch_Number,
    Bill_of_Lading,
    Tracking_Number,
    Storage_Location,
    Repair_Materil_Number,
    Last_Updated_Dt,
    Processed,
    Process_Dt,
    Error,
    Error_Message,
    Process_Id,
    _FileDate
    FROM {{ ref('ODS__THREEPL__TPL_SHIPMENT_LINE_DETAIL') }} as s
    {% if is_incremental() %} WHERE _FileDate > IFNULL((SELECT MAX(_FileDate) FROM {{ this }}),'1970-01-01') {% endif %}
	QUALIFY (ROW_NUMBER() OVER (PARTITION BY Document_Number,Line_Number,Sequence_Number ORDER BY _Filedate DESC )) = 1
)

,transform_data as
(
    SELECT 
    Document_Number,
    Line_Number,
    Sequence_Number,
    TPL_Order_Number,
    Material_Number,
    Quantity,
    Serial_Number,
    WMS_Batch_Number,
    Bill_of_Lading,
    Tracking_Number,
    Storage_Location,
    Repair_Materil_Number,
    Last_Updated_Dt,
    Processed,
    Process_Dt,
    Error,
    Error_Message,
    Process_Id,
    _FILEDATE,
    '{{ invocation_id }}' AS AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
    FROM source_data
)

,type_data as 
(
    SELECT
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
         CAST(PROCESS_ID AS NUMBER(38,0)) AS PROCESS_ID,
         CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
         CAST(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
         CAST(_ROW_HASH as varchar(128)) as _ROW_HASH       
    FROM transform_data
    )
    
SELECT * FROM type_data