{{ config(
      materialized='view',
      alias='REPLENISHMENTORDER',
      transient=false
) }}

with source_data as (
    SELECT
      WAREHOUSE_ORDER_NO,
      POSITION_NO,
      SEQUENCE_NO,
      ITEM,
      ITEM_DESCRIPTION,
      SHIP_TO,
      SHIP_FROM,
      ORDER_DATE,
      PLANNED_DELIVERY_DATE,
      PLANNED_RECEIPT_DATE,
      ACT_DELIVERY_DATE,
      ACT_RECEIPT_DATE,
      UNIT_OF_MEASURE,
      ORDERED_QTY,
      RECEIVED_QTY,
      RECEIPT_NO,
      REFERENCE,
      OB_LINE_STATUS,
      IB_LINE_STATUS,
      LOGON_CODE,
      INFORMATION

    from {{ ref('COMMON__BAAN__REPLENISHMENTORDER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data