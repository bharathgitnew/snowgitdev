/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.41.23"
*************/

{{ config(
      materialized='view',
      alias='TPL_Shipment_Line_Detail',
      transient=false
) }}

with source_data as (
    SELECT
        DOCUMENT_NUMBER,
        LINE_NUMBER,
        SEQUENCE_NUMBER,
        TPL_ORDER_NUMBER,
        MATERIAL_NUMBER,
        QUANTITY,
        SERIAL_NUMBER,
        WMS_BATCH_NUMBER,
        BILL_OF_LADING,
        TRACKING_NUMBER,
        STORAGE_LOCATION,
        REPAIR_MATERIL_NUMBER,
        LAST_UPDATED_DT,
        PROCESSED,
        PROCESS_DT,
        ERROR,
        ERROR_MESSAGE,
        PROCESS_ID
    from {{ ref('ODS__THREEPL__TPL_SHIPMENT_LINE_DETAIL') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data