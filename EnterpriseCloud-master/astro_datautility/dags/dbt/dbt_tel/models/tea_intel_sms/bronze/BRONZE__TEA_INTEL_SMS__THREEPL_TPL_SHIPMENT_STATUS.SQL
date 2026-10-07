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
    alias='THREEPL_TPL_SHIPMENT_STATUS',
    unique_key = ['DOCUMENT_NUMBER',
    'LINE_NUMBER']
) }}


with source_data as 
(
    SELECT JSONFIELD:"Document_Number"::STRING AS Document_Number, 
         JSONFIELD:"Line_Number"::NUMBER AS Line_Number,  
         JSONFIELD:"TPL_Order_Number"::STRING  AS TPL_Order_Number, 
         JSONFIELD:"Current_Status"::STRING  AS Current_Status,  
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"EDI_Generated_Dt" ,'/Date()/')) AS EDI_Generated_Dt, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Order_Created_Dt" ,'/Date()/')) AS Order_Created_Dt, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Order_Accepted_Dt" ,'/Date()/')) AS Order_Accepted_Dt, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Ready_For_Shipment_Dt" ,'/Date()/')) AS Ready_For_Shipment_Dt, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Order_Delivered_Dt" ,'/Date()/')) AS Order_Delivered_Dt, 
         JSONFIELD:"Proof_of_Delivery"::STRING AS Proof_of_Delivery, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Order_Canceled_Dt" ,'/Date()/')) AS Order_Canceled_Dt,
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Shipment_Delayed_Dt" ,'/Date()/')) AS Shipment_Delayed_Dt,
         JSONFIELD:"Shipment_Note_Text"::STRING AS Shipment_Note_Text, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Last_Updated_Dt" ,'/Date()/')) AS Last_Updated_Dt, 
         JSONFIELD:"Processed"::SMALLINT AS Processed, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Process_Dt" ,'/Date()/')) AS Process_Dt, 
         JSONFIELD:"Error"::BOOLEAN AS Error,
         JSONFIELD:"Error_Message"::STRING AS Error_Message, 
         JSONFIELD:"Process_Id"::INT AS Process_Id,
         _FileDate
        FROM {{ source("THREEPL", "TPL_SHIPMENT_STATUS") }} as s
        {% if is_tel_incremental() %} WHERE _FileDate > IFNULL((SELECT MAX(_FileDate) FROM {{ this }}),'1970-01-01') {% endif %}
		QUALIFY (ROW_NUMBER() OVER (PARTITION BY Document_Number,Line_Number ORDER BY _Filedate DESC )) = 1
)
,	transform_data as
(
    SELECT 
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		source_data._FileDate  AS _FILEDATE,
		source_data.Document_Number	 AS	DOCUMENT_NUMBER,
		source_data.Line_Number	 AS	 LINE_NUMBER,
		source_data.TPL_Order_Number AS TPL_ORDER_NUMBER,
		source_data.Current_Status	AS CURRENT_STATUS,
		source_data.EDI_Generated_Dt AS EDI_GENERATED_DT,
		source_data.Order_Created_Dt AS ORDER_CREATED_DT,
		source_data.Order_Accepted_Dt AS ORDER_ACCEPTED_DT,
		source_data.Ready_For_Shipment_Dt AS READY_FOR_SHIPMENT_DT,
		source_data.Order_Delivered_Dt	AS ORDER_DELIVERED_DT,
		source_data.Proof_of_Delivery	AS PROOF_OF_DELIVERY,
		source_data.Order_Canceled_Dt	AS ORDER_CANCELED_DT,
		source_data.Shipment_Delayed_Dt	AS SHIPMENT_DELAYED_DT,
		source_data.Shipment_Note_Text	AS SHIPMENT_NOTE_TEXT,
		source_data.Last_Updated_Dt	  AS LAST_UPDATED_DT,
		source_data.Processed AS PROCESSED,
		source_data.Process_Dt	AS	PROCESS_DT,
		source_data.Error AS ERROR,
		source_data.Error_Message AS ERROR_MESSAGE,
		source_data.Process_Id AS PROCESS_ID 
        FROM source_data
        )
,	type_data as 
(
    select
		CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		CAST(_ROW_HASH as varchar(128)) as _ROW_HASH,
		CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
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
		CAST(PROCESS_ID AS VARCHAR(16777216)) AS PROCESS_ID
    from transform_data
    )
select * from type_data