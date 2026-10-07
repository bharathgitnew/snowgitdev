{{ config(
      materialized='view',
      alias='TPL_Receiving_Advice',
      transient=false
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
    from {{ ref('COMMON__THREEPL__TPL_RECEIVING_ADVICE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data