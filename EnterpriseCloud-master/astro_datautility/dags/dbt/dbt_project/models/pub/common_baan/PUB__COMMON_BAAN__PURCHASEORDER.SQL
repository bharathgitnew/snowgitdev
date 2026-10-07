{{ config(
      materialized='view',
      alias='PURCHASEORDER',
      transient=false
) }}

with source_data as (
    SELECT
        PO_NO,
        PO_POSITION_NO,
        PO_SEQUENCE_NO,
        LINE_TYPE,
        ORDER_TYPE,
        ITEM,
        ITEM_DESCRIPTION,
        PO_STATISTICS_GROUP,
        ORDERED_AMOUNT,
        ORDERED_QTY,
        DELIVERED_QTY,
        BACK_ORDER_QTY,
        INVOICED_QTY,
        UNIT_OF_MEASURE,
        COST_PRICE,
        ITEM_PURCHASE_PRICE,
        PO_LINE_PRICE,
        INVOICED_AMT,
        ORDER_DATE,
        ORDER_TIME,
        PLANNED_DELIVERY_DATE,
        CONFIRMED_DELIVERY_DATE,
        SUPPLIER_RESPONSE_DATE,
        CHANGED_DELIVERY_DATE,
        RECEIPT_DATE,
        INVOICE_DATE,
        INVOICE_NUMBER,
        CONSUMABLE,
        PLANNER,
        BUYER,
        PROJECT,
        WAREHOUSE,
        HEADER_WAREHOUSE,
        CURRENT_ACTIVITY_SESSION,
        BUYFROM_BPID,
        SUPPLIER,
        REFERENCEA,
        REFERENCEB,
        PURCHASE_LEDGER_ACCOUNT,
        PURCHASE_LEDGER_DESCRIPTION,
        DIMENSION1,
        DIMENSION2,
        DIMENSION3,
        DIMENSION4,
        COST_COMPONENT,
        SUPPLIER_GROUP,
        ACT_FOB_NARITA_DATE,
        CANCELLED,
        ORDER_PRIORITY,
        CURRENCY,
        CURRENCY_RATE,
        CURRENT_PLANNED_DELIVERY_DATE,
        CARRIER,
        SUPPLIER_ORDER_NO
    from {{ ref('COMMON__BAAN__PURCHASEORDER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data