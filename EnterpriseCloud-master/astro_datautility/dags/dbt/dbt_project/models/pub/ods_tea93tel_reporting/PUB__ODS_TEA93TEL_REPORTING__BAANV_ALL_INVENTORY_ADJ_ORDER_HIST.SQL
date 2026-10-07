/************
Model file generated from dbtGeneratePubViews: 10.03.2022.08.31.46"
*************/

{{ config(
      materialized='view',
      alias='BAANV_ALL_INVENTORY_ADJ_ORDER_HIST',
      transient=false
) }}

with source_data as (
    SELECT
        COMPANY,
        ORDER_NO,
        COUNT_NO,
        ORDER_TYPE,
        WAREHOUSE_HEADER,
        EMPLOYEE_NO,
        REASON_CODE,
        PROCESS_COUNT,
        TRANSACTION_DATE_HEADER,
        POSITION_NO,
        WAREHOUSE_LINE,
        LOCATION_CODE,
        ITEM,
        LOT,
        DATE_LINE,
        STORAGE_UNIT,
        QTY_INVENTORY_UNIT,
        QTY_STORAGE_UNIT,
        ACTUAL_INV_INVENTORY_UNIT,
        ACTUAL_INV_STORAGE_UNIT,
        VARIANCE_INVENTORY_UNIT,
        VARIANCE_STORAGE_UNIT,
        COUNTED_INVENTORY_YN,
        COUNT_DATE,
        REASON_FINANCE,
        REASON_DESC,
        RECOUNT,
        USE_ADJUSTMENT_PRICE,
        APPROVAL,
        REASON_CODE_FOR_VARIANCE,
        LINE_TRANSACTION_DATE
    from {{ ref('ODS__TEA93TEL_REPORTING__BAANV_ALL_INVENTORY_ADJ_ORDER_HIST') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data