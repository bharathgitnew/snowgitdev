{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='ROSETTA_CONSIGNMENT_SHIPMENT_RECEIPT',
    unique_key = ['Message_ID',
     'Message_Line_Nbr']
) }}

with source_data as
(
    SELECT _Filename as _Filename,
        _Filedate as _Filedate,
        JSONFIELD:"Message_ID" :: STRING AS Message_ID,
        JSONFIELD:"Message_Line_Nbr" :: INT AS Message_Line_Nbr,
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Message_Dt" ,
        '/Date()/')) AS Message_Dt,
        JSONFIELD:"Customer_Stockroom" :: STRING AS Customer_Stockroom,
        JSONFIELD:"Item_Code" :: STRING AS Item_Code,
        JSONFIELD:"Qty" :: INT AS Qty,
        JSONFIELD:"Shipment_Tracking_ID" :: STRING AS Shipment_Tracking_ID,
        JSONFIELD:"Process_ID" :: STRING AS Process_ID,
        JSONFIELD:"Processed" :: INT AS Processed,
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Process_Dt" ,
        '/Date()/')) AS Process_Dt,
        JSONFIELD:"Error_Message" :: STRING AS Error_Message,
        JSONFIELD:"Error" :: BOOLEAN AS Error
    FROM {{ source("ROSETTA", "CONSIGNMENT_SHIPMENT_RECEIPT") }}
    {% if is_tel_incremental() %}WHERE  _FileDate > IFNULL((SELECT MAX(_FileDate) FROM {{ this }}),'1970-01-01'){% endif %}
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY Message_ID, Message_Line_Nbr ORDER BY _FILENAME DESC,_FILEDATE DESC )) = 1
),
	transform_data as
(
    SELECT
		_FILENAME,
		_FILEDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		MESSAGE_ID,
		MESSAGE_LINE_NBR,
		MESSAGE_DT,
		CUSTOMER_STOCKROOM,
		ITEM_CODE,
		QTY,
		SHIPMENT_TRACKING_ID,
		PROCESS_ID,
		PROCESSED,
		PROCESS_DT,
		ERROR_MESSAGE,
		ERROR 
        FROM source_data
 )
 ,	type_data as
 (
     select
		CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
		CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		CAST(MESSAGE_ID AS VARCHAR(16777216)) AS MESSAGE_ID,
		CAST(MESSAGE_LINE_NBR AS NUMBER(38,0)) AS MESSAGE_LINE_NBR,
		CAST(MESSAGE_DT AS TIMESTAMP_NTZ(9)) AS MESSAGE_DT,
		CAST(CUSTOMER_STOCKROOM AS VARCHAR(16777216)) AS CUSTOMER_STOCKROOM,
		CAST(ITEM_CODE AS VARCHAR(16777216)) AS ITEM_CODE,
		CAST(QTY AS NUMBER(38,0)) AS QTY,
		CAST(SHIPMENT_TRACKING_ID AS VARCHAR(16777216)) AS SHIPMENT_TRACKING_ID,
		CAST(PROCESS_ID AS VARCHAR(16777216)) AS PROCESS_ID,
		CAST(PROCESSED AS NUMBER(38,0)) AS PROCESSED,
		CAST(PROCESS_DT AS TIMESTAMP_NTZ(9)) AS PROCESS_DT,
		CAST(ERROR_MESSAGE AS VARCHAR(16777216)) AS ERROR_MESSAGE,
		CAST(ERROR AS BOOLEAN) AS ERROR
    FROM transform_data
 )
 SELECT * FROM type_data