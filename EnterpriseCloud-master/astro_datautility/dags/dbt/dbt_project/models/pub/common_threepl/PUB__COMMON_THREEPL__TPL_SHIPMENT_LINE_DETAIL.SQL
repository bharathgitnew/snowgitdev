{{ config(
      materialized='view',
      alias='TPL_SHIPMENT_LINE_DETAIL',
      transient=false
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
    _FILEDATE
    FROM {{ ref('COMMON__THREEPL__TPL_SHIPMENT_LINE_DETAIL') }}
)

,transform_data as 
(
    SELECT * FROM source_data
)

SELECT * FROM transform_data