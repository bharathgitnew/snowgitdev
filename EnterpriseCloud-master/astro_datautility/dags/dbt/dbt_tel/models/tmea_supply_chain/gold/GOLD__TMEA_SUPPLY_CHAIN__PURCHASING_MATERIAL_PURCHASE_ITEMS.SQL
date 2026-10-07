{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='PURCHASING_MATERIAL_PURCHASE_ITEMS',
    	transient=false
) }}

WITH ref_cte_GENERAL_MATERIAL_DATA
AS (
	SELECT *
	FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__GENERAL_MATERIAL_DATA') }}
	),
ref_cte_MATERIAL_DESCRIPTIONS
AS (
	SELECT *
	FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_DESCRIPTIONS') }}
	),
ref_cte_MATERIAL_GROUP_DESCRIPTIONS
AS (
	SELECT *
	FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_GROUP_DESCRIPTIONS') }}
	),
ref_cte_MATERIAL_VALUATION
AS (
	SELECT *
	FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_VALUATION') }}
	),
ref_cte_PLANT_DATA_FOR_MATERIAL
AS (
	SELECT *
	FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PLANT_DATA_FOR_MATERIAL') }}
	),
ref_cte_PROFIT_CENTER_DESCRIPTION
AS (
	SELECT *
	FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PROFIT_CENTER_DESCRIPTION') }}
	),
ref_cte_PURCHASING_GROUPS
AS (
	SELECT *
	FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PURCHASING_GROUPS') }}
	),
Source AS (
	SELECT marc.material_number,
		MARC.procurement_type,
		MBEW.standard_price,
		MBEW.price_unit,
		MBEW.standard_price / MBEW.price_unit AS NET_price,
		MBEW.valuation_area,
		MARC.PLANT,
		gm.cross_plant_material_status,
		mdes.material_description,
		gm.material_group,
		mtgdes.material_group_description,
		gm.base_unit_of_measure,
		gm.purchase_order_unit_of_measure,
		MARC.abc_indicator,
		MARC.purchasing_group,
		pg.description_of_purchasing_group,
		MARC.mrp_type,
		MARC.total_replenishment_lead_time_in_workdays AS Planning_lead_Time,
		MARC.goods_receipt_processing_time_in_days,
		MARC.reorder_point,
		MARC.safety_stock,
		MARC.minimum_lot_size,
		MARC.base_quantity,
		MARC.profit_center,
		prof.general_name AS profit_center_description
	FROM ref_cte_PLANT_DATA_FOR_MATERIAL AS marc
	LEFT JOIN ref_cte_MATERIAL_VALUATION AS MBEW ON MBEW.material_number = marc.material_number AND marc.plant = MBEW.valuation_area
	LEFT JOIN ref_cte_GENERAL_MATERIAL_DATA AS gm ON gm.material_number = marc.material_number
	LEFT JOIN ref_cte_MATERIAL_DESCRIPTIONS AS mdes ON mdes.material_number = marc.material_number
	LEFT JOIN ref_cte_MATERIAL_GROUP_DESCRIPTIONS AS mtgdes ON mtgdes.material_group = gm.material_group
	LEFT JOIN ref_cte_PROFIT_CENTER_DESCRIPTION AS prof ON prof.profit_center = MARC.profit_center
	LEFT JOIN ref_cte_PURCHASING_GROUPS AS pg ON pg.purchasing_group = MARC.purchasing_group
	WHERE pg.SPOOL_OUTPUT_DEVICE = 'EMAI' AND MARC.PLANT = '0010'
	),
	-- // Extraction Oen purchase orders
open_po
AS (
	SELECT poa.material_number,
		sum(poa.open_gr) AS OPEN_PO_QTY,
		max(net_price) AS PO_Price,
		max(purchasing_document_number) AS Latest_PO,
		COUNT(DISTINCT POA.PURCHASING_DOCUMENT_NUMBER) AS Total_Open_PO
	FROM {{ ref('GOLD__TMEA_SUPPLY_CHAIN__PURCHASING_ORDER_METRIC_OPEN_AGING') }} AS poa
	GROUP BY poa.material_number
	),
	-- // Extracting Inventory on hand 
Stock
AS (
	SELECT wtm.material_number,
		sum(wtm.unrestricted) AS WAREHOUSE_STOCK
	FROM {{ ref('GOLD__TMEA_SUPPLY_CHAIN__DISPLAY_WAREHOUSE_STOCKS_OF_MATERIALS') }} AS wtm
	WHERE wtm.storage_location = '0010'
	GROUP BY wtm.material_number
	),
OUTPUT
AS (
	SELECT Source.material_number,
		Source.procurement_type,
		Source.standard_price,
		Source.price_unit,
		Source.NET_price,
		Source.valuation_area,
		Source.PLANT,
		Source.cross_plant_material_status,
		Source.material_description,
		Source.material_group,
		Source.material_group_description,
		Source.base_unit_of_measure,
		Source.purchase_order_unit_of_measure,
		Source.abc_indicator,
		Source.purchasing_group,
		Source.description_of_purchasing_group,
		Source.mrp_type,
		Source.Planning_lead_Time,
		Source.goods_receipt_processing_time_in_days,
		Source.reorder_point,
		Source.safety_stock,
		Source.minimum_lot_size,
		Source.base_quantity,
		Source.profit_center,
		Source.profit_center_description,
		WAREHOUSE_STOCK,
		OPEN_PO_QTY,
		PO_Price,
		Latest_PO,
		Total_Open_PO
	FROM source
	LEFT JOIN Stock AS stock ON stock.material_number = source.material_number
	LEFT JOIN open_po AS open_po ON open_po.material_number = source.material_number
	),
source_data
AS (
	SELECT DISTINCT 		MATERIAL_NUMBER,
		PROCUREMENT_TYPE,
		STANDARD_PRICE,
		PRICE_UNIT,
		NET_PRICE,
		VALUATION_AREA,
		PLANT,
		CROSS_PLANT_MATERIAL_STATUS,
		MATERIAL_DESCRIPTION,
		MATERIAL_GROUP,
		MATERIAL_GROUP_DESCRIPTION,
		BASE_UNIT_OF_MEASURE,
		PURCHASE_ORDER_UNIT_OF_MEASURE,
		ABC_INDICATOR,
		PURCHASING_GROUP,
		DESCRIPTION_OF_PURCHASING_GROUP,
		MRP_TYPE,
		PLANNING_LEAD_TIME,
		GOODS_RECEIPT_PROCESSING_TIME_IN_DAYS,
		REORDER_POINT,
		SAFETY_STOCK,
		MINIMUM_LOT_SIZE,
		BASE_QUANTITY,
		PROFIT_CENTER,
		PROFIT_CENTER_DESCRIPTION,
		WAREHOUSE_STOCK,
		OPEN_PO_QTY,
		PO_PRICE,
		LATEST_PO,
		TOTAL_OPEN_PO
	FROM
	OUTPUT
	WHERE profit_center_description IS NOT NULL AND PROCUREMENT_TYPE = 'F'
	),
transform_data
AS (
	SELECT '{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		MATERIAL_NUMBER,
		PROCUREMENT_TYPE,
		STANDARD_PRICE,
		PRICE_UNIT,
		NET_PRICE,
		VALUATION_AREA,
		PLANT,
		CROSS_PLANT_MATERIAL_STATUS,
		MATERIAL_DESCRIPTION,
		MATERIAL_GROUP,
		MATERIAL_GROUP_DESCRIPTION,
		BASE_UNIT_OF_MEASURE,
		PURCHASE_ORDER_UNIT_OF_MEASURE,
		ABC_INDICATOR,
		PURCHASING_GROUP,
		DESCRIPTION_OF_PURCHASING_GROUP,
		MRP_TYPE,
		PLANNING_LEAD_TIME,
		GOODS_RECEIPT_PROCESSING_TIME_IN_DAYS,
		REORDER_POINT,
		SAFETY_STOCK,
		MINIMUM_LOT_SIZE,
		BASE_QUANTITY,
		PROFIT_CENTER,
		PROFIT_CENTER_DESCRIPTION,
		WAREHOUSE_STOCK,
		OPEN_PO_QTY,
		PO_PRICE,
		LATEST_PO,
		TOTAL_OPEN_PO
	FROM source_data
	),

type_data AS (
    SELECT 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        MATERIAL_NUMBER,
        PROCUREMENT_TYPE,
        CAST(STANDARD_PRICE AS NUMBER(38,2)) AS STANDARD_PRICE,
        CAST(PRICE_UNIT AS NUMBER(38,2)) AS PRICE_UNIT,
        CAST(NET_PRICE AS NUMBER(38,2)) AS NET_PRICE,
        VALUATION_AREA,
        PLANT,
        CROSS_PLANT_MATERIAL_STATUS,
        MATERIAL_DESCRIPTION,
        MATERIAL_GROUP,
        MATERIAL_GROUP_DESCRIPTION,
        BASE_UNIT_OF_MEASURE,
        PURCHASE_ORDER_UNIT_OF_MEASURE,
        ABC_INDICATOR,
        PURCHASING_GROUP,
        DESCRIPTION_OF_PURCHASING_GROUP,
        MRP_TYPE,
        CAST(PLANNING_LEAD_TIME AS NUMBER(38,0)) AS PLANNING_LEAD_TIME,
        GOODS_RECEIPT_PROCESSING_TIME_IN_DAYS,
        CAST(REORDER_POINT AS NUMBER(38,0)) AS REORDER_POINT,
        CAST(SAFETY_STOCK AS NUMBER(38,0)) AS SAFETY_STOCK,
        CAST(MINIMUM_LOT_SIZE AS NUMBER(38,0)) AS MINIMUM_LOT_SIZE,
        CAST(BASE_QUANTITY AS NUMBER(38,0)) AS BASE_QUANTITY,
        PROFIT_CENTER,
        PROFIT_CENTER_DESCRIPTION,
        CAST(WAREHOUSE_STOCK AS NUMBER(38,0)) AS WAREHOUSE_STOCK,
        CAST(OPEN_PO_QTY AS NUMBER(38,0)) AS OPEN_PO_QTY,
        PO_PRICE,
        LATEST_PO,
        TOTAL_OPEN_PO
    FROM transform_data
)

SELECT *
FROM type_data