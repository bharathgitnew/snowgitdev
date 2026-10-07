{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='THREEPL_TPL_RECEIVING_ADVICE',
    unique_key = ['Receiving_Advice_Id']
) }}


with source_data as (
    SELECT
        JSONFIELD:"Receiving_Advice_Id"::STRING AS Receiving_Advice_Id,
        JSONFIELD:"Trading_Partner"::STRING AS Trading_Partner,
        JSONFIELD:"ASN_Number"::STRING AS ASN_Number,
        JSONFIELD:"Document_Number"::STRING AS Document_Number,
        JSONFIELD:"Line_Number"::STRING AS Line_Number,
        JSONFIELD:"Material_Number"::STRING AS Material_Number,
        JSONFIELD:"WMS_Batch"::STRING AS WMS_Batch,
        JSONFIELD:"Receipt_Quantity"::STRING AS Receipt_Quantity,
        JSONFIELD:"Serial_Number"::STRING AS Serial_Number,
        JSONFIELD:"Bill_of_Lading"::STRING AS Bill_of_Lading,
        JSONFIELD:"Tracking_number"::STRING AS Tracking_number,
        JSONFIELD:"TPL_Reference"::STRING AS TPL_Reference,
        JSONFIELD:"Storage_Location"::STRING AS Storage_Location,
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Goods_Receipt_Dt" ,'/Date()/')) AS Goods_Receipt_Dt,
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Shelf_Life_Expiration_Dt" ,'/Date()/')) AS Shelf_Life_Expiration_Dt,
        JSONFIELD:"Country_Of_Origin"::STRING AS Country_Of_Origin,
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Manufacture_Dt" ,'/Date()/')) AS Manufacture_Dt,
        JSONFIELD:"Repair_Material_Number"::STRING AS Repair_Material_Number,
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Load_Dt" ,'/Date()/')) AS Load_Dt,
        JSONFIELD:"Processed"::STRING AS Processed,
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Process_Dt" ,'/Date()/')) AS Process_Dt,
        JSONFIELD:"Error"::STRING AS Error,
        JSONFIELD:"Error_Message"::STRING AS Error_Message,
        JSONFIELD:"Process_Id"::STRING AS Process_Id,
        _filedate as _FILEDATE
    FROM {{ source('THREEPL','TPL_RECEIVING_ADVICE') }}
    {% if is_tel_incremental() %} WHERE _FILEDATE > IFNULL((SELECT MAX(_FILEDATE) FROM {{ this }}),'1970-01-01') {% endif %}
	QUALIFY (ROW_NUMBER() OVER (PARTITION BY Receiving_Advice_Id ORDER BY _FILEDATE DESC )) = 1
),

	transform_data as(
    select
		_FILEDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		Receiving_Advice_Id,
		Document_Number,
		Line_Number,
		Trading_Partner,
		ASN_Number,
		Material_Number,
		WMS_Batch,
		Receipt_Quantity,
		Serial_Number,
		Bill_of_Lading,
		Tracking_number,
		TPL_Reference,
		Storage_Location,
		Goods_Receipt_Dt,
		Shelf_Life_Expiration_Dt,
		Country_Of_Origin,
		Manufacture_Dt,
		Repair_Material_Number,
		Load_Dt,
		Processed,
		Process_Dt,
		Error,
		Error_Message,
		Process_Id
    from source_data
),

	type_data as(
    select
		CAST(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
		CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		CAST(_ROW_HASH as varchar(128)) as _ROW_HASH,
		CAST(Receiving_Advice_Id AS VARCHAR(16777216)) AS Receiving_Advice_Id,
		CAST(Document_Number AS VARCHAR(16777216)) AS Document_Number,
		CAST(Line_Number AS VARCHAR(16777216)) AS Line_Number,
		CAST(Trading_Partner AS VARCHAR(16777216)) AS Trading_Partner,
		CAST(ASN_Number AS VARCHAR(16777216)) AS ASN_Number,
		CAST(Material_Number AS VARCHAR(16777216)) AS Material_Number,
		CAST(WMS_Batch AS VARCHAR(16777216)) AS WMS_Batch,
		CAST(Receipt_Quantity AS VARCHAR(16777216)) AS Receipt_Quantity,
		CAST(Serial_Number AS VARCHAR(16777216)) AS Serial_Number,
		CAST(Bill_of_Lading AS VARCHAR(16777216)) AS Bill_of_Lading,
		CAST(Tracking_number AS VARCHAR(16777216)) AS Tracking_number,
		CAST(TPL_Reference AS VARCHAR(16777216)) AS TPL_Reference,
		CAST(Storage_Location AS VARCHAR(16777216)) AS Storage_Location,
		CAST(Goods_Receipt_Dt AS TIMESTAMP_NTZ(9)) AS Goods_Receipt_Dt,
		CAST(Shelf_Life_Expiration_Dt AS TIMESTAMP_NTZ(9)) AS Shelf_Life_Expiration_Dt,
		CAST(Country_Of_Origin AS VARCHAR(16777216)) AS Country_Of_Origin,
		CAST(Manufacture_Dt AS TIMESTAMP_NTZ(9)) AS Manufacture_Dt,
		CAST(Repair_Material_Number AS VARCHAR(16777216)) AS Repair_Material_Number,
		CAST(Load_Dt AS TIMESTAMP_NTZ(9)) AS Load_Dt,
		CAST(Processed AS VARCHAR(16777216)) AS Processed,
		CAST(Process_Dt AS TIMESTAMP_NTZ(9)) AS Process_Dt,
		CAST(Error AS VARCHAR(16777216)) AS Error,
		CAST(Error_Message AS VARCHAR(16777216)) AS Error_Message,
		CAST(Process_Id AS VARCHAR(16777216)) AS Process_Id
    from transform_data
)
select * from type_data