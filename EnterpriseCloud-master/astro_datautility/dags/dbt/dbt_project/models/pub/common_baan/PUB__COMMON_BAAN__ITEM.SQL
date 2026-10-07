/************
Model file generated from dbtGeneratePubViews: 04.08.2022.10.56.59"
*************/

{{ config(
      materialized='view',
      alias='ITEM',
      transient=false
) }}

with source_data as (
    SELECT
        PROJECT_ITEM,
        PROJECT,
        ITEM,
        ITEM_DESCRIPTION,
        ITEM_TYPE,
        ITEM_GROUP,
        ON_HAND_QTY,
        ON_ORDER_QTY,
        ALLOCATED_QTY,
        ECONOMIC_QTY,
        SIGNAL_CODE,
        JAPAN_PRODUCT_LINE,
        CONSUMABLE,
        PURCHASE_PRICE,
        SALES_PRICE,
        MAT_SURCHARGE,
        MAT_COST,
        COST_PRICE,
        LEAD_TIME,
        SAFETY_TIME,
        MIN_ORDER_QTY,
        INVENTORY_UNIT,
        PURCHASE_UNIT,
        PURCHASE_PRICE_UNIT,
        STAT_GROUP,
        SUPPLIER_GROUP,
        PLANNER,
        LAST_INV_TRANS_DATE,
        LAST_PP_DATE,
        LAST_SP_DATE,
        LAST_CP_DATE,
        ORDER_QTY_MULTIPLE_OF,
        CUMULATIVE_ISSUE,
        WAREHOUSE,
        REPAIR_FLAG,
        INTEL_FLAG,
        REMARKS,
        BUYER_CODE,
        INSPECTION,
        COUNTRY_OF_ORIGIN,
        AVERAGE_PURCHASE_PRICE,
        LATEST_PURCHASE_PRICE,
        HARMONIZED_TARIFF_CODE,
        ECCN,
        SCHEDULEB,
        COMMODITY_CODE,
        PRODUCT_TYPE,
        SELECTION_CODE,
        WEIGHT,
        SALES_UNIT,
        SALES_PRICE_UNIT,
        RETURN_FLAG,
        ABC_GLOBAL,
        ABC_LOCAL,
        ABC_INTEL,
        MANUFACTURER,
        MANUFACTURER_NAME,
        ITEM_SIZE,
        EBIZ_DISCLOSURE_FLAG,
        SALES_MIN_QTY,
        PHYSICS_MATERIAL,
        EXPORT_REGULATION_FLAG,
        EXPORT_REGULATION_DESC,
        OBJECT_GROUP,
        FS_FLAG,
        DPAL_FLAG,
        EOL_FLAG,
        WEIGHT_UNIT,
        WEIGHT_WITH_PACKAGE,
        UN_NUMBER,
        PACKING_SIZE_L,
        PACKING_SIZE_W,
        PACKING_SIZE_H,
        BOXCODE,
        CRITICALITY_SCORE,
        ALLOCATION
    from {{ ref('COMMON__BAAN__ITEM') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data