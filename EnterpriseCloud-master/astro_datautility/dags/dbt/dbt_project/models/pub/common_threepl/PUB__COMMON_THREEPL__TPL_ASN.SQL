{{ config(
      materialized='view',
      alias='TPL_ASN',
      transient=false
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
    from {{ ref('COMMON__THREEPL__TPL_ASN') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data