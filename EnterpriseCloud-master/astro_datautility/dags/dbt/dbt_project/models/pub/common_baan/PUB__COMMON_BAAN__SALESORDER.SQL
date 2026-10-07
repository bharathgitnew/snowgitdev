{{ config(
      materialized='view',
      alias='SALESORDER',
      transient=false
) }}

with source_data as (
    SELECT
      SALES_ORDER_NO,
      POSITION_NO,
      SEQUENCE_NO,
      ORDER_LINE_TYPE,
      INVOICE_NO,
      STATUS,
      WAREHOUSE,
      CURRENT_ACTIVITY_SESSION,
      INVOICETO_BPID,
      INVOICETO_BP,
      SOLDTO_BPID,
      SOLDTO_BP,
      ITEM,
      ITEM_DESCRIPTION,
      ORDER_TYPE,
      COST_PRICE_COMPONENT,
      UNIT_OF_MEASURE,
      ORDERED_QTY,
      DELIVERED_QTY,
      BACK_ORDER_QTY,
      ORDER_DATE,
      ORDER_DT,
      CUSTOMER_REQUEST_DATE,
      CUSTOMER_REQUEST_DT,
      PLAN_DELIVERY_DATE,
      PLAN_DELIVERY_DT,
      DELIVERY_DATE,
      DELIVERY_DT,
      INVOICE_DATE,
      INVOICE_DT,
      ORIGINAL_COMMIT_DATE,
      ORIGINAL_COMMIT_DT,
      STANDARD_COST_PRICE,
      PRICE,
      PRICE_SOURCE,
      ORDER_AMOUNT,
      INVOICE_AMOUNT,
      DISCOUNT_PERCENT,
      CUSTOMER_PO_NO,
      REFERENCEA,
      REFERENCEB,
      SALES_REP,
      DIRECT_DELIVERY,
      PURCHASE_ORDER_NO,
      AREA,
      TRANSACTION_TYPE,
      INVOICE_STATUS,
      WAREHOUSE_STATUS,
      CANCELLED,
      CANCELLED_DATE,
      ORDER_PRIORITY,
      TAX_CODE,
      CUSTOMER_ORDER_POSITION,
      ROUTE,
      CURRENCY,
      CHANNEL,
      SERIAL_NO,
      INVOICE_BY_INSTALLMENT

    from {{ ref('COMMON__BAAN__SALESORDER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data