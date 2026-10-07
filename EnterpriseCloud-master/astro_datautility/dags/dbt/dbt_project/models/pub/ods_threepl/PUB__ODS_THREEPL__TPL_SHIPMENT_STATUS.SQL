/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.41.23"
*************/

{{ config(
      materialized='view',
      alias='TPL_Shipment_Status',
      transient=false
) }}

with source_data as (
    SELECT
        DOCUMENT_NUMBER,
        LINE_NUMBER,
        TPL_ORDER_NUMBER,
        CURRENT_STATUS,
        EDI_GENERATED_DT,
        ORDER_CREATED_DT,
        ORDER_ACCEPTED_DT,
        READY_FOR_SHIPMENT_DT,
        ORDER_DELIVERED_DT,
        PROOF_OF_DELIVERY,
        ORDER_CANCELED_DT,
        SHIPMENT_DELAYED_DT,
        SHIPMENT_NOTE_TEXT,
        LAST_UPDATED_DT,
        PROCESSED,
        PROCESS_DT,
        ERROR,
        ERROR_MESSAGE,
        PROCESS_ID
    from {{ ref('ODS__THREEPL__TPL_SHIPMENT_STATUS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data