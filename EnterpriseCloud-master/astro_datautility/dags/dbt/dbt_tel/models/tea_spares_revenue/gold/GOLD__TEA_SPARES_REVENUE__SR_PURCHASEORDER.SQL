{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SR_PURCHASEORDER'
) }}


with purchase_order_ref as (
  select 
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
    from {{ ref('SILVER__TEA_SPARES_REVENUE__PURCHASEORDER') }}
)

,source_data as (
    SELECT 
      PO.PO_NO||'_'||PO.PO_Position_no AS POLine, 
      PO.ITEM, 
      PO.ITEM_DESCRIPTION, 
      PO.SUPPLIER_ORDER_NO, 
      PO.SUPPLIER, 
      PO.ORDERED_QTY,
      PO.DELIVERED_QTY, 
      PO.ORDER_DATE, 
      PO.WAREHOUSE,
      ORDER_PRIORITY 
      FROM purchase_order_ref AS PO 
      WHERE PO.ORDER_DATE>'2014-01-01'
      AND PO.CANCELLED ilike 'No' 
      GROUP BY PO.PO_NO||'_'||PO.PO_Position_no,
      PO.ITEM, 
      PO.ITEM_DESCRIPTION,
      PO.SUPPLIER_ORDER_NO, 
      PO.SUPPLIER,
      PO.ORDERED_QTY, 
      PO.DELIVERED_QTY, 
      PO.ORDER_DATE, 
      PO.WAREHOUSE, 
      PO.CANCELLED,
      PO.ORDER_PRIORITY
      HAVING (((PO.PO_NO||'_'||PO.PO_Position_no) ilike 'r%')
      AND ((PO.SUPPLIER_ORDER_NO) ilike 'h%' 
      Or (PO.SUPPLIER_ORDER_NO) ilike 'es%' 
      Or (PO.SUPPLIER_ORDER_NO) ilike 'ds%' 
      Or (PO.SUPPLIER_ORDER_NO) ilike 't%' 
      Or (PO.SUPPLIER_ORDER_NO) ilike 'c%' 
      Or (PO.SUPPLIER_ORDER_NO) ilike 'l1%' 
      Or (PO.SUPPLIER_ORDER_NO) ilike 'mb%' 
      Or (PO.SUPPLIER_ORDER_NO) ilike 'Sr%' 
      Or (PO.SUPPLIER_ORDER_NO) ilike 'r%' 
      Or (PO.SUPPLIER_ORDER_NO) ilike 'p%' 
      Or (PO.SUPPLIER_ORDER_NO) ilike 'ss%' 
      Or (PO.SUPPLIER_ORDER_NO) ilike 'g7%' 
      Or (PO.SUPPLIER_ORDER_NO) ilike 'vd%' 
      Or (PO.SUPPLIER_ORDER_NO) ilike 'm%' 
      Or (PO.SUPPLIER_ORDER_NO) ilike 'n%')
      AND ((PO.ORDER_DATE)>'2014-01-01') 
      And ((PO.CANCELLED) ilike 'No'))
      OR (((PO.ITEM)ilike 'h%' 
      Or (PO.ITEM) ilike 'es%' 
      Or (PO.ITEM) ilike 'ds%' 
      Or (PO.ITEM) ilike 't%' 
      Or (PO.ITEM) ilike 'c%' 
      Or (PO.ITEM) ilike 'l1%' 
      Or (PO.ITEM) ilike 'mb%' 
      Or (PO.ITEM) ilike 'Sr%' 
      Or (PO.ITEM) ilike 'r%' 
      Or (PO.ITEM) ilike 'p%' 
      Or (PO.ITEM) ilike 'ss%' 
      Or (PO.ITEM) ilike 'g7%' 
      Or (PO.ITEM) ilike 'vd%' 
      Or (PO.ITEM) ilike 'm%' 
      Or (PO.ITEM) ilike 'n%')
      AND ((PO.ORDER_DATE)>'2014-01-01') 
      And ((PO.CANCELLED) ilike 'No'))
      ORDER BY PO.ORDER_DATE
)

,transform_data as (
  select 
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
    POLINE,
    ITEM,
    ITEM_DESCRIPTION,
    SUPPLIER_ORDER_NO,
    SUPPLIER,
    ORDERED_QTY,
    DELIVERED_QTY,
    ORDER_DATE,
    WAREHOUSE,
    ORDER_PRIORITY
  from source_data
)

,type_data as 
(
    select
        _AUDIT_LOG_ID,
        _ROW_HASH,
        POLINE,
        ITEM,
        ITEM_DESCRIPTION,
        SUPPLIER_ORDER_NO,
        SUPPLIER,
        cast(ORDERED_QTY as NUMBER(15,2)) as ORDERED_QTY,
        cast(DELIVERED_QTY as NUMBER(15,2)) as DELIVERED_QTY,
        cast(ORDER_DATE as TIMESTAMP_NTZ(9)) as ORDER_DATE,
        WAREHOUSE,
        ORDER_PRIORITY
    from transform_data
    )
select * from type_data