{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias = 'LOGISTICS_INVENTORY_MANAGEMENT_SUMMARIZED_HISTORICAL',
        unique_key = ['MATERIAL_NUMBER',
    'REPORT_DATE'],
        transient = false
) }}


WITH source_data AS (
    SELECT * exclude (_AUDIT_LOG_ID, _ROW_HASH )
    FROM {{ ref('GOLD__TMEA_SUPPLY_CHAIN__LOGISTICS_INVENTORY_MANAGEMENT_SUMMARIZED') }}
    ),
transform_data AS (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
	    SHA2('hash_me') as _ROW_HASH,
        current_timestamp() as REPORT_DATE,
        *
    from source_data
    ),
type_data AS (
    SELECT
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(REPORT_DATE as timestamp_ltz(9)) as REPORT_DATE,
        MATERIAL_DESCRIPTION,
        MATERIAL_NUMBER,
        CROSS_PLANT_MATERIAL_STATUS,
        PROCUREMENT_TYPE,
        MATERIAL_GROUP,
        PLANNED_DELIVERY_TIME_IN_DAYS,
        LANGUAGE_KEY,
        PLANT,
        ABC_INDICATOR,
        PURCHASING_GROUP,
        MRP_TYPE,
        REORDER_POINT,
        MINIMUM_LOT_SIZE,
        MAXIMUM_STOCK_LEVEL,
        PROFIT_CENTER,
        INDICATOR_BULK_MATERIAL,
        NET_PRICE,
        SAFETY_STOCK_QTY,
        SAFETY_STOCK_AMOUNT,
        TOTAL_DEMAND_QTY,
        GROSS_DEMAND_QTY,
        TOTAL_SUPPLY_QTY,
        TOTAL_STOCK_OH_QTY,
        TOTAL_EXCESS_QTY,
        GROSS_SUPPLY,
        TOTAL_OVERSUPPLY_QTY,
        TOTAL_SUPPLY_AMOUNT,
        TOTAL_STOCK_OH_AMOUNT,
        TOTAL_EXCESS_AMOUNT,
        TOTAL_GROSS_DEMAND_AMOUNT,
        TOTAL_OVERSUPPLY_AMOUNT,
        TOTAL_INV_BALANCE
     from transform_data
    )

SELECT *
FROM type_data