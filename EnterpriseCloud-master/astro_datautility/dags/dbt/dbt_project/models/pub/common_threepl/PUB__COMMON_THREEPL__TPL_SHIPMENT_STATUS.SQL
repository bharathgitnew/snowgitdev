{{ config(
      materialized='view',
      alias='TPL_SHIPMENT_STATUS',
      transient=false
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
    FROM {{ ref('COMMON__THREEPL__TPL_SHIPMENT_STATUS') }}
)

,transform_data as 
(
    SELECT * FROM source_data
)

SELECT * FROM transform_data