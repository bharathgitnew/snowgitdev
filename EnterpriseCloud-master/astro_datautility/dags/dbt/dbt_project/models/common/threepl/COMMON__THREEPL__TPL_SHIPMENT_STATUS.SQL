{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='TPL_SHIPMENT_STATUS',
    unique_key = ['DOCUMENT_NUMBER',
    'LINE_NUMBER']
) }}

with source_data as 
(
    SELECT
    Document_Number,
    Line_Number,
    TPL_Order_Number,
    Current_Status,
    EDI_Generated_Dt,
    Order_Created_Dt,
    Order_Accepted_Dt,
    Ready_For_Shipment_Dt,
    Order_Delivered_Dt,
    Proof_of_Delivery,
    Order_Canceled_Dt,
    Shipment_Delayed_Dt,
    Shipment_Note_Text,
    Last_Updated_Dt,
    Processed,
    Process_Dt,
    Error,
    Error_Message,
    Process_Id,
    _FileDate
    FROM {{ ref('ODS__THREEPL__TPL_SHIPMENT_STATUS') }} as s
    {% if is_incremental() %} WHERE _FileDate > IFNULL((SELECT MAX(_FileDate) FROM {{ this }}),'1970-01-01') {% endif %}
	QUALIFY (ROW_NUMBER() OVER (PARTITION BY Document_Number,Line_Number ORDER BY _Filedate DESC )) = 1
)

,transform_data as
(
    SELECT 
    Document_Number,
    Line_Number,
    TPL_Order_Number,
    Current_Status,
    EDI_Generated_Dt,
    Order_Created_Dt,
    Order_Accepted_Dt,
    Ready_For_Shipment_Dt,
    Order_Delivered_Dt,
    Proof_of_Delivery,
    Order_Canceled_Dt,
    Shipment_Delayed_Dt,
    Shipment_Note_Text,
    Last_Updated_Dt,
    Processed,
    Process_Dt,
    Error,
    Error_Message,
    Process_Id,
    _FileDate,
    '{{ invocation_id }}' AS AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh. 
    FROM source_data
)

,type_data as 
(
    SELECT
         CAST(DOCUMENT_NUMBER AS VARCHAR(16777216))	AS	DOCUMENT_NUMBER,
         CAST(LINE_NUMBER AS NUMBER(38,0))	AS LINE_NUMBER,
         CAST(TPL_ORDER_NUMBER AS VARCHAR(16777216))	AS TPL_ORDER_NUMBER,
         CAST(CURRENT_STATUS AS	VARCHAR(16777216))	AS CURRENT_STATUS,
         CAST(EDI_GENERATED_DT AS TIMESTAMP_NTZ(9))	AS EDI_GENERATED_DT,
         CAST(ORDER_CREATED_DT AS TIMESTAMP_NTZ(9))	AS ORDER_CREATED_DT,
         CAST(ORDER_ACCEPTED_DT AS TIMESTAMP_NTZ(9)) AS	ORDER_ACCEPTED_DT,
         CAST(READY_FOR_SHIPMENT_DT AS TIMESTAMP_NTZ(9)) AS	READY_FOR_SHIPMENT_DT,
         CAST(ORDER_DELIVERED_DT AS	TIMESTAMP_NTZ(9)) AS ORDER_DELIVERED_DT,
         CAST(PROOF_OF_DELIVERY AS VARCHAR(16777216)) AS PROOF_OF_DELIVERY,
         CAST(ORDER_CANCELED_DT AS TIMESTAMP_NTZ(9)) AS	ORDER_CANCELED_DT,
         CAST(SHIPMENT_DELAYED_DT AS TIMESTAMP_NTZ(9))	AS SHIPMENT_DELAYED_DT,
         CAST(SHIPMENT_NOTE_TEXT AS	VARCHAR(16777216))	AS SHIPMENT_NOTE_TEXT,
         CAST(LAST_UPDATED_DT AS TIMESTAMP_NTZ(9))	AS LAST_UPDATED_DT,
         CAST(PROCESSED AS VARCHAR(16777216)) AS	PROCESSED,
         CAST(PROCESS_DT AS	TIMESTAMP_NTZ(9)) AS PROCESS_DT,
         CAST(ERROR AS VARCHAR(16777216)) AS ERROR,
         CAST(ERROR_MESSAGE AS VARCHAR(16777216)) AS ERROR_MESSAGE,
         CAST(PROCESS_ID AS VARCHAR(16777216)) AS PROCESS_ID,
         CAST(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
         CAST(_ROW_HASH as varchar(128)) as _ROW_HASH,
         CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
    FROM transform_data
)
SELECT * FROM type_data