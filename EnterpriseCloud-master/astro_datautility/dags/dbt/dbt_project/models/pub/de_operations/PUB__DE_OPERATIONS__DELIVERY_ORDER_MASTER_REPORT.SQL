{{ config(
      materialized='view',
      schema='DE_OPERATIONS',
      alias='DELIVERY_ORDER_MASTER_REPORT',
      transient=false
) }}


with source_data as (
    select
        HEADER_TYPE,
        DOC_HEADER,
        HEADER_DOC_LINE,
        DELIVERY_HEADER,
        DELIVERY_LINE,
        DELIVERY_ID,
        MATERIAL_NUMBER,
        MATERIAL_DESCRIPTION,
        ORIGINATING_DOC_HEADER,
        ORIGINATING_DOC_LINE,
        REFERNCE_DOC_HEADER,
        REFERENCE_DOC_LINE,
        SHIP_DATE,
        STORAGE_LOC,
        STORAGE_LOC_NAME,
        PLANT,
        REQUESTED_DELIVERY_DATE,
        DELIVERY_DATE,
        DELIVERY_DATE_Z,
        CONF_WH_DELIVERY_DATE,
        SCHED_WH_DELIVERY_DATE,
        PLANNED_DELIVERY_DATE,
        PURCHASE_ORDER_QTY,
        ACTUAL_DEL_QTY,
        DELAY_STATUS,
        DELIVERY_STATUS,
        MOVEMENT_STATUS,
        PLANNED_GOODS_MOVE_DATE
    FROM {{ ref('COMMON__REPORTS__DELIVERY_ORDER_MASTER_REPORT') }}


),

transform_data AS
(
    select * from source_data
)

    select * from transform_data