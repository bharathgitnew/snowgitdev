{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='TPL_ASN',
    unique_key = ['ASN_Id']
) }}


with source_data as (
    SELECT
        ASN_Id,
        Document_Number,
        Line_Number,
        Material_Number,
        Part_Description,
        WMS_Batch,
        Expected_Quantity,
        Serial_Number,
        Storage_Location,
        Ship_Dt,
        Repair_Material_Number,
        Dual_Use,
        ASN_Number,
        Trading_Partner,
        Load_Dt,
        Processed,
        Process_Dt,
        Error,
        Error_Message,
        Process_ID,
        Load_ID,
        Purchase_Order_Number,
        Purchase_Order_Line_Number,
        _FILEDATE
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__THREEPL_TPL_ASN') }}
),

	transform_data as(
    select
		_FILEDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		ASN_Id,
		Document_Number,
		Line_Number,
		Material_Number,
		Part_Description,
		WMS_Batch,
		Expected_Quantity,
		Serial_Number,
		Storage_Location,
		Ship_Dt,
		Repair_Material_Number,
		Dual_Use,
		ASN_Number,
		Trading_Partner,
		Load_Dt,
		Processed,
		Process_Dt,
		Error,
		Error_Message,
		Process_ID,
		Load_ID,
		Purchase_Order_Number,
		Purchase_Order_Line_Number
    from source_data
),

	type_data as(
    select
		CAST(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
		CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		CAST(_ROW_HASH as varchar(128)) as _ROW_HASH,
		CAST(ASN_Id AS VARCHAR(16777216)) AS ASN_Id,
		CAST(Document_Number AS VARCHAR(16777216)) AS Document_Number,
		CAST(Line_Number AS VARCHAR(16777216)) AS Line_Number,
		CAST(Material_Number AS VARCHAR(16777216)) AS Material_Number,
		CAST(Part_Description AS VARCHAR(16777216)) AS Part_Description,
		CAST(WMS_Batch AS VARCHAR(16777216)) AS WMS_Batch,
		CAST(Expected_Quantity AS VARCHAR(16777216)) AS Expected_Quantity,
		CAST(Serial_Number AS VARCHAR(16777216)) AS Serial_Number,
		CAST(Storage_Location AS VARCHAR(16777216)) AS Storage_Location,
		CAST(Ship_Dt AS TIMESTAMP_NTZ(9)) AS Ship_Dt,
		CAST(Repair_Material_Number AS VARCHAR(16777216)) AS Repair_Material_Number,
		CAST(Dual_Use AS VARCHAR(16777216)) AS Dual_Use,
		CAST(ASN_Number AS VARCHAR(16777216)) AS ASN_Number,
		CAST(Trading_Partner AS VARCHAR(16777216)) AS Trading_Partner,
		CAST(Load_Dt AS TIMESTAMP_NTZ(9)) AS Load_Dt,
		CAST(Processed AS VARCHAR(16777216)) AS Processed,
		CAST(Process_Dt AS TIMESTAMP_NTZ(9)) AS Process_Dt,
		CAST(Error AS VARCHAR(16777216)) AS Error,
		CAST(Error_Message AS VARCHAR(16777216)) AS Error_Message,
		CAST(Process_ID AS VARCHAR(16777216)) AS Process_ID,
		CAST(Load_ID AS VARCHAR(16777216)) AS Load_ID,
		CAST(Purchase_Order_Number AS VARCHAR(16777216)) AS Purchase_Order_Number,
		CAST(Purchase_Order_Line_Number AS VARCHAR(16777216)) AS Purchase_Order_Line_Number
    from transform_data
)
select * from type_data