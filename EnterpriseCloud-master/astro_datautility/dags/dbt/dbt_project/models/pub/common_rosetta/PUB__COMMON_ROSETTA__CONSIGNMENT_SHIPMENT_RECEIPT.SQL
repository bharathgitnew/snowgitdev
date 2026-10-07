{{ config(
    materialized='view',
    alias='CONSIGNMENT_SHIPMENT_RECEIPT'
) }}

with source_data as 
(
    SELECT
        _FILENAME,
        _FILEDATE,
        MESSAGE_ID,
        MESSAGE_LINE_NBR,
        MESSAGE_DT,
        CUSTOMER_STOCKROOM,
        ITEM_CODE,
        QTY,
        SHIPMENT_TRACKING_ID,
        PROCESS_ID,
        PROCESSED,
        PROCESS_DT,
        ERROR_MESSAGE,
        ERROR
        FROM {{ ref('COMMON__ROSETTA__CONSIGNMENT_SHIPMENT_RECEIPT') }}
)

,transform_data as
(
    SELECT * FROM source_data
)

SELECT * FROM transform_data