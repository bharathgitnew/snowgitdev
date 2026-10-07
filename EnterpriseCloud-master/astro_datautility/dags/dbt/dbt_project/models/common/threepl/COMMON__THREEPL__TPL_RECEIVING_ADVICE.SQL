{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='TPL_Receiving_Advice',
    unique_key = ['Receiving_Advice_Id']
) }}


with source_data as (
    SELECT 
        Receiving_Advice_Id,
        Trading_Partner,
        ASN_Number,
        Document_Number,
        Line_Number,
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
        Process_Id,
        _FILEDATE
    FROM {{ ref('ODS__THREEPL__TPL_RECEIVING_ADVICE') }}
),

transform_data as(
    select
        Receiving_Advice_Id,
        Trading_Partner,
        ASN_Number,
        Document_Number,
        Line_Number,
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
        Process_Id,
        _FILEDATE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
    from source_data
),

type_data as(
    select
        CAST(Receiving_Advice_Id AS VARCHAR(16777216)) AS Receiving_Advice_Id,
        CAST(Trading_Partner AS VARCHAR(16777216)) AS Trading_Partner,
        CAST(ASN_Number AS VARCHAR(16777216)) AS ASN_Number,
        CAST(Document_Number AS VARCHAR(16777216)) AS Document_Number,
        CAST(Line_Number AS VARCHAR(16777216)) AS Line_Number,
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
        CAST(Process_Id AS VARCHAR(16777216)) AS Process_Id,
        CAST(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        CAST(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        CAST(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
)
select * from type_data