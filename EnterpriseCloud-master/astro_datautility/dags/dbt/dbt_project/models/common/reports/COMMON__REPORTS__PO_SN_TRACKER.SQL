{{ config(
        alias = 'PO_SN_TRACKER',
        materialized='incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with MAT_PLANT as (
  select 
    distinct MARC_MATERIAL_NUMBER, 
    MARC_SERIAL_NUMBER_PROFILE as PROFILE_ID 
  from 
     {{ ref('COMMON__SAPH__MATERIAL_PLANT_MASTER') }}
  where 
    MARC_PLANT = '3200'
), 
sales as (
  select 
    SALES_DOC_TYPE, 
    SALES_DOC_TYPE_DESCRIPTION, 
    STORAGE_LOCATION, 
    SALES_ORDER_HEADER_NUMBER, 
    SALES_ORDER_LINE_NUMBER, 
    SALES_ORDER_QUANTITY, 
    MATERIAL_NUMBER, 
    CUSTOMER_REFERENCE, 
    SOLD_TO_PARTY_CODE, 
    SOLD_TO_PARTY 
  from 
    {{ ref('COMMON__SAPH__SALES_ORDER_LINE_MASTER') }}
  where 
    SALES_DOC_TYPE = 'ZP10'
), 
delivery as (
  select 
    concat(HDR, LINE_POSNR) as delivery, 
    DELIVERY_TYPE_CODE, 
    HDR, 
    LINE_POSNR, 
    BATCH, 
    REF_DOC_HDR, 
    REF_DOC_LINE, 
    SHIP_TO_PARTY_CODE, 
    QTY, 
    ACTUAL_GOODS_MOVEMENT_DATE, 
    LISTAGG(WMS_BATCH_NUMBER, '|') as WMS_BATCH_NUMBER, 
    LISTAGG(SERIAL_NUMBER, '|') as SERIAL_NUMBER 
  from 
    {{ ref('COMMON__SAPH__DELIVERY_ORDER_LINE_MASTER_PUB') }}
    left join {{ ref('ODS__THREEPL__TPL_SHIPMENT_LINE_DETAIL') }} as THREEPL on try_to_number(DOCUMENT_NUMBER) = try_to_number(HDR) 
    and try_to_number(LINE_NUMBER) = try_to_number(LINE_POSNR) 
  where 
    BATCH <> '' 
    and DELIVERY_TYPE_CODE = 'ZP10' 
  group by 
    DELIVERY_TYPE_CODE, 
    HDR, 
    LINE_POSNR, 
    BATCH, 
    REF_DOC_HDR, 
    REF_DOC_LINE, 
    SHIP_TO_PARTY_CODE, 
    QTY, 
    ACTUAL_GOODS_MOVEMENT_DATE
), 
Souce_data as (
  select 
    SALES_DOC_TYPE, 
    SALES_DOC_TYPE_DESCRIPTION, 
    SALES_ORDER_HEADER_NUMBER as Sales_order, 
    SALES_ORDER_LINE_NUMBER, 
    sales.STORAGE_LOCATION, 
    SOLD_TO_PARTY_CODE, 
    SOLD_TO_PARTY, 
    CUSTOMER_REFERENCE, 
    delivery.SHIP_TO_PARTY_CODE, 
    SALES_ORDER_QUANTITY, 
    delivery.HDR as DELIVERY_NUMBER, 
    delivery.DELIVERY_TYPE_CODE as DELIVERY_TYPE, 
    delivery.ACTUAL_GOODS_MOVEMENT_DATE, 
    delivery.LINE_POSNR as DELIVERY_LINE, 
    delivery.QTY as DELIVERY_QTY, 
    SAles.MATERIAL_NUMBER, 
    mat_plant.PROFILE_ID, 
    delivery.BATCH, 
    WMS_BATCH_NUMBER as WMS_BATCH, 
    SERIAL_NUMBER 
  from 
    sales 
    inner join delivery as delivery on delivery.REF_DOC_HDR = sales.SALES_ORDER_HEADER_NUMBER 
    and delivery.REF_DOC_LINE = sales.SALES_ORDER_LINE_NUMBER 
    left join MAT_PLANT as MAT_PLANT on MAT_PLANT.MARC_MATERIAL_NUMBER = sales.MATERIAL_NUMBER
) ,
 transform_data AS (
    SELECT
      SHA2('hash_me')                AS _ROW_HASH,
      '{{ invocation_id }}'          AS _AUDIT_LOG_ID,
      SALES_DOC_TYPE,
      SALES_DOC_TYPE_DESCRIPTION,
      SALES_ORDER,
      SALES_ORDER_LINE_NUMBER,
      STORAGE_LOCATION,
      SOLD_TO_PARTY_CODE,
      SOLD_TO_PARTY,
      CUSTOMER_REFERENCE,
      SHIP_TO_PARTY_CODE,
      SALES_ORDER_QUANTITY,
      DELIVERY_NUMBER,
      DELIVERY_TYPE,
      ACTUAL_GOODS_MOVEMENT_DATE,
      DELIVERY_LINE,
      DELIVERY_QTY,
      MATERIAL_NUMBER,
      PROFILE_ID,
      BATCH,
      WMS_BATCH,
      SERIAL_NUMBER
    FROM Souce_data
  ),

  type_data AS (
    SELECT
      _ROW_HASH,
      _AUDIT_LOG_ID,
      SALES_DOC_TYPE,
      SALES_DOC_TYPE_DESCRIPTION,
      SALES_ORDER,
      SALES_ORDER_LINE_NUMBER,
      STORAGE_LOCATION,
      SOLD_TO_PARTY_CODE,
      SOLD_TO_PARTY,
      CUSTOMER_REFERENCE,
      SHIP_TO_PARTY_CODE,
      CAST(SALES_ORDER_QUANTITY      AS NUMBER(38,10)) AS SALES_ORDER_QUANTITY,
      DELIVERY_NUMBER,
      DELIVERY_TYPE,
      CAST(ACTUAL_GOODS_MOVEMENT_DATE AS DATE)         AS ACTUAL_GOODS_MOVEMENT_DATE,
      DELIVERY_LINE,
      CAST(DELIVERY_QTY               AS NUMBER(38,10)) AS DELIVERY_QTY,
      MATERIAL_NUMBER,
      PROFILE_ID,
      BATCH,
      WMS_BATCH,
      SERIAL_NUMBER
    FROM transform_data
  )

SELECT *
FROM type_data