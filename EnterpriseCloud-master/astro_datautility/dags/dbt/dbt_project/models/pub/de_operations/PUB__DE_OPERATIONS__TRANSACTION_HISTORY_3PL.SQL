{{ config(
      materialized='view',
      schema='DE_OPERATIONS',
      alias='TRANSACTION_HISTORY_3PL',
      transient=false
) }}


with source_data as (
    select
        MOVEMENT_TYPE,
        MOVEMENT_TYPE_DESC,
        MATDOC_DOCUMENT_TYPE,
        USER_NAME,
        DOCUMENT_NUMBER,
        DOCUMENT_ITEM,
        SO,
        SO_LINE,
        PO,
        PO_LINE,
        DO_NUMBER,
        DO_LINE,
        SAP_BATCH_NUMBER,
        MATERIAL,
        PLANT,
        STORAGE_LOCATION,
        CONSIGNMENT_CUSTOMER,
        CUSTOMER_NAME,
        SLOC_CUSTOMER_COMBINED,
        ENTRY_DATE,
        ENTRY_TIME,
        CST_TIME_STAMP,
        CST_ENTRY_DATE,
        CST_ENTRY_TIME,
        UTC_ENTRY_DATE,
        UTC_ENTRY_TIME,
        UTC_TIMESTAMP,
        TRANSACTION_QTY,
        TRANSACTION_VALUE,
        PRODUCT_CODE,
        LOCAL_ABC,
        INTEL_ABC,
        CONSUMABLE,
        INTEL,
        TPL_ORDER_NUMBER,
        TPL_STORAGE_LOCATION,
        QUANTITY,
        TRACKING_NUMBER,
        SHIP_STATUS_3PL_ORDER_NO,
        CURRENT_STATUS,
        EDI_GENERATED_DT,
        ORDER_CREATED_DT,
        ORDER_ACCEPTED_DT,
        READY_FOR_SHIPMENT_DT,
        ORDER_DELIVERED_DT,
        SHIPMENT_ROUTE,
        HEADER_TEXT,
        HAWB,
        SHIP_CONF_TRACKING_NUMBER,
        SERVICE_LEVEL,
        FORWARDER
    FROM {{ ref('COMMON__REPORTS__TRANSACTION_HISTORY_3PL') }}


),

transform_data AS
(
    select * from source_data
)

    select * from transform_data