{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='TPL_ASN',
    unique_key = ['ASN_Id']
) }}


with source_data as (
    SELECT 
        JSONFIELD:"ASN_Id"::STRING AS ASN_Id,
        JSONFIELD:"Document_Number"::STRING AS Document_Number,
        JSONFIELD:"Line_Number"::STRING AS Line_Number,
        JSONFIELD:"Material_Number"::STRING AS Material_Number,
        JSONFIELD:"Part_Description"::STRING AS Part_Description,
        JSONFIELD:"WMS_Batch"::STRING AS WMS_Batch,
        JSONFIELD:"Expected_Quantity"::STRING AS Expected_Quantity,
        JSONFIELD:"Serial_Number"::STRING AS Serial_Number,
        JSONFIELD:"Storage_Location"::STRING AS Storage_Location,
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Ship_Dt" ,'/Date()/')) AS Ship_Dt,
        JSONFIELD:"Repair_Material_Number"::STRING AS Repair_Material_Number,
        JSONFIELD:"Dual_Use"::STRING AS Dual_Use,
        JSONFIELD:"ASN_Number"::STRING AS ASN_Number,
        JSONFIELD:"Trading_Partner"::STRING AS Trading_Partner,
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Load_Dt",'/Date()/')) AS Load_Dt,
        JSONFIELD:"Processed"::STRING AS Processed,
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"Process_Dt",'/Date()/'))	 AS Process_Dt,
        JSONFIELD:"Error"::STRING AS Error,
        JSONFIELD:"Error_Message"::STRING AS Error_Message,
        JSONFIELD:"Process_ID"::STRING AS Process_ID,
        JSONFIELD:"Load_ID"::STRING AS Load_ID,
        JSONFIELD:"Purchase_Order_Number"::STRING AS Purchase_Order_Number,
        JSONFIELD:"Purchase_Order_Line_Number"::STRING AS Purchase_Order_Line_Number,
        _filedate as _FILEDATE
    FROM {{ source('THREEPL','TPL_ASN') }}
  {% if is_incremental() %} WHERE _FILEDATE > IFNULL((SELECT MAX(_FILEDATE) FROM {{ this }}),'1970-01-01') {% endif %}
	QUALIFY (ROW_NUMBER() OVER (PARTITION BY ASN_Id ORDER BY _FILEDATE DESC )) = 1
),

transform_data as(
    select
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
        _FILEDATE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
    from source_data
),

type_data as(
    select
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
        CAST(Purchase_Order_Line_Number AS VARCHAR(16777216)) AS Purchase_Order_Line_Number,
        CAST(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        CAST(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        CAST(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
)
select * from type_data