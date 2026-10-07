{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='PURCHASING_MATERIAL_REPORT',
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
ref_cte_PURCHASING_INFO_RECORD_GENERAL_DATA
AS (
	SELECT *
	FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PURCHASING_INFO_RECORD_GENERAL_DATA') }}
	),
ref_cte_PURCHASING_INFO_RECORD_PURCHASING_ORGANIZATION_DATA
AS (
	SELECT *
	FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PURCHASING_INFO_RECORD_PURCHASING_ORGANIZATION_DATA') }}
	),
ref_cte_PURCHASING_SOURCE_LIST
AS (
	SELECT *
	FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PURCHASING_SOURCE_LIST') }}
	),
ref_cte_VENDOR_MASTER
AS (
	SELECT *
	FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__VENDOR_MASTER') }}
	),
MATERIAL_MASTER AS (
	SELECT DISTINCT MARC.plant,
		MARA.material_number,
		MAKT.material_description,
		MARA.material_group,
		T023T.material_group_description,
		MARA.base_unit_of_measure,
		MARA.purchase_order_unit_of_measure,
		MARC.abc_indicator,
		MARC.purchasing_group,
		T024.description_of_purchasing_group,
		MARC.mrp_type,
		MARC.planned_delivery_time_in_days AS Planning_lead_Time,
		MARC.goods_receipt_processing_time_in_days,
		MARC.procurement_type,
		MARC.reorder_point,
		MARC.safety_stock,
		MARC.minimum_lot_size,
		MARC.base_quantity,
		MARC.profit_center,
		CEPC.general_name AS profit_center_description,
		MARA.cross_plant_material_status,
		MBEW.valuation_area,
		MBEW.standard_price,
		MBEW.price_unit,
		MBEW.standard_price / MBEW.price_unit AS NET_STANDARD_PRICE,
		EORD.vendors_account_number,
		EORD.blocked_source_of_supply,
		LFA1.name_1 AS Supplier_Name,
		EORD.indicator_fixed_vendor,
		EORD.source_list_usage_in_materials_planning,
		MARC.country_of_origin_of_the_material,
		CONCAT (
			MARA.material_number,
			EORD.vendors_account_number
			) AS PrimaryKey,
		LIMS.TOTAL_STOCK_OH_QTY,
		LIMS.TOTAL_DEMAND_QTY,
		LIMS.TOTAL_EXCESS_QTY,
		LIP.OPEN_PO_QTY,
		LIP.DEAD_INV_5Y,
		LIP.DEAD_INV_12M,
		LIP.PO_CYCLE_TIME_AVG,
		LIP.TOTAL_12_CONSUMPTION,
		CASE WHEN EORD.indicator_fixed_vendor = 'X' THEN 'Primary' ELSE 'Other' END AS Supplier_Type
	FROM ref_cte_GENERAL_MATERIAL_DATA AS MARA
	LEFT JOIN ref_cte_PLANT_DATA_FOR_MATERIAL AS MARC ON MARC.material_number = MARA.material_number
	LEFT JOIN ref_cte_MATERIAL_DESCRIPTIONS AS MAKT ON MAKT.material_number = MARA.material_number
	LEFT JOIN ref_cte_PURCHASING_SOURCE_LIST AS EORD ON EORD.material_number = MARA.material_number AND EORD.plant = MARC.plant
	LEFT JOIN ref_cte_MATERIAL_VALUATION AS MBEW ON MBEW.material_number = MARC.material_number AND MBEW.valuation_area = MARC.plant
	LEFT JOIN ref_cte_MATERIAL_GROUP_DESCRIPTIONS AS T023T ON T023T.material_group = MARA.material_group
	LEFT JOIN ref_cte_PROFIT_CENTER_DESCRIPTION AS CEPC ON CEPC.profit_center = MARC.profit_center
	LEFT JOIN ref_cte_VENDOR_MASTER AS LFA1 ON EORD.vendors_account_number = LFA1.account_number_of_vendor_or_creditor
	LEFT JOIN ref_cte_PURCHASING_GROUPS AS T024 ON T024.purchasing_group = MARC.purchasing_group
	LEFT JOIN {{ ref('GOLD__TMEA_SUPPLY_CHAIN__LOGISTICS_INVENTORY_MANAGEMENT_SUMMARIZED') }} AS LIMS ON LIMS.MATERIAL_NUMBER = MARA.MATERIAL_NUMBER
	LEFT JOIN {{ ref('GOLD__TMEA_SUPPLY_CHAIN__LOGISTICS_INVENTORY_PLANNER') }} AS LIP ON LIP.MATERIAL_NUMBER = MARA.MATERIAL_NUMBER
	WHERE T024.SPOOL_OUTPUT_DEVICE = 'EMAI' AND MBEW.valuation_area IN ('0010') AND EORD.is_deleted = 'No' AND EORD.VENDORS_ACCOUNT_NUMBER <> ' '
	),
INFORECORDS
AS (
	SELECT DISTINCT EINA.material_number,
		E1EINEM.plant,
		EINA.material_number_used_by_vendor,
		EINA.number_of_purchasing_info_record,
		EINA.vendor_s_account_number,
		EINA.purchase_order_unit_of_measure,
		EINA.base_unit_of_measure,
		E1EINEM.net_price_in_purchasing_info_record,
		E1EINEM.price_valid_until,
		E1EINEM.planned_delivery_time_in_days AS Info_rec_lead_time
	FROM ref_cte_PURCHASING_INFO_RECORD_GENERAL_DATA AS EINA
	JOIN ref_cte_PURCHASING_INFO_RECORD_PURCHASING_ORGANIZATION_DATA AS E1EINEM ON EINA.number_of_purchasing_info_record = E1EINEM.number_of_purchasing_info_record
	WHERE EINA.vendor_material_group IS NOT NULL AND E1EINEM.NUMBER_OF_PURCHASING_INFO_RECORD IS NOT NULL AND E1EINEM.PURCHASING_INFO_RECORD_CATEGORY NOT IN ('2', '3') AND E1EINEM.purchasing_organization = '0040' AND E1EINEM.plant = '0010'
	),
vendor_perf
AS (
	SELECT vp.material,
		vp.RECEIPT_DATE,
		vp.NEED_DATE,
		vp.RECEIPT_DATE,
		VP.RCPT_QTY,
		MONTHNAME(vp.RECEIPT_DATE) AS Month_Name,
		datediff(day, vp.NEED_DATE, vp.RECEIPT_DATE) AS Commit_Days_DIFF,
		datediff(day, vp.PO_CREATE_DATE, vp.RECEIPT_DATE) AS PO_Cycle_Time,
		dateadd(day, - day(getdate()), getdate()) AS LASTmONTH,
		DATEADD(month, - 12, LASTmONTH) AS firstMonth
	FROM {{ ref('GOLD__TMEA_SUPPLY_CHAIN__PURCHASING_VENDOR_PERFORMANCE') }} AS vp
	WHERE vp.receipt_date > '2019-12-31' AND vp.receipt_date BETWEEN firstMonth AND LASTmONTH
	),
totals_vendor_perf
AS (
	SELECT vendor_perf.material,
		avg(Commit_Days_DIFF) AS AVg_Days_Late,
		COUNT(CASE WHEN Commit_Days_DIFF <= 2 THEN 1 END) AS LINES_ON_TIME,
		COUNT(vendor_perf.material) AS TOTAL_LINES_RECEIVED,
		LINES_ON_TIME / TOTAL_LINES_RECEIVED AS OTD
	FROM vendor_perf AS vendor_perf
	GROUP BY vendor_perf.material
	),
LAST_PO
AS (
	SELECT *
	FROM (
		SELECT material,
			receipt_date,
			purchase_order,
			row_number() OVER (
				PARTITION BY material ORDER BY receipt_date DESC
				) AS rn
		FROM {{ ref('GOLD__TMEA_SUPPLY_CHAIN__PURCHASING_VENDOR_PERFORMANCE') }}
		) t
	WHERE t.rn = 1
	),
final
AS (
	SELECT DISTINCT MATERIAL_MASTER.PrimaryKey,
		MATERIAL_MASTER.plant,
		MATERIAL_MASTER.material_number,
		MATERIAL_MASTER.material_description,
		INFORECORDS.material_number_used_by_vendor,
		INFORECORDS.number_of_purchasing_info_record,
		MATERIAL_MASTER.material_group,
		MATERIAL_MASTER.material_group_description,
		MATERIAL_MASTER.purchase_order_unit_of_measure,
		MATERIAL_MASTER.abc_indicator,
		MATERIAL_MASTER.purchasing_group,
		MATERIAL_MASTER.description_of_purchasing_group AS Buyer_Name,
		INFORECORDS.base_unit_of_measure,
		INFORECORDS.net_price_in_purchasing_info_record ,
		MATERIAL_MASTER.minimum_lot_size,
		MATERIAL_MASTER.standard_price,
		MATERIAL_MASTER.price_unit,
		MATERIAL_MASTER.NET_STANDARD_PRICE,
		MATERIAL_MASTER.mrp_type,
		INFORECORDS.Info_rec_lead_time,
		MATERIAL_MASTER.Planning_lead_Time,
		MATERIAL_MASTER.goods_receipt_processing_time_in_days AS GR_Time,
		MATERIAL_MASTER.procurement_type,
		MATERIAL_MASTER.reorder_point,
		MATERIAL_MASTER.safety_stock,
		MATERIAL_MASTER.profit_center,
		MATERIAL_MASTER.profit_center_description,
		MATERIAL_MASTER.cross_plant_material_status,
		INFORECORDS.price_valid_until,
		MATERIAL_MASTER.vendors_account_number,
		MATERIAL_MASTER.blocked_source_of_supply,
		MATERIAL_MASTER.supplier_name,
		MATERIAL_MASTER.indicator_fixed_vendor,
		MATERIAL_MASTER.source_list_usage_in_materials_planning,
		MATERIAL_MASTER.country_of_origin_of_the_material,
		ZEROIFNULL(MATERIAL_MASTER.OPEN_PO_QTY) AS TOTAL_OPEN_PO_QTY,
		MATERIAL_MASTER.TOTAL_STOCK_OH_QTY AS TOTAL_STOCK_OH_QTY,
		MATERIAL_MASTER.TOTAL_DEMAND_QTY AS TOTAL_DEMAND_QTY,
		MATERIAL_MASTER.TOTAL_EXCESS_QTY AS TOTAL_EXCESS_QTY,
		MATERIAL_MASTER.DEAD_INV_5Y AS DEAD_INV_5Y,
		MATERIAL_MASTER.DEAD_INV_12M AS DEAD_INV_1Y,
		MATERIAL_MASTER.PO_CYCLE_TIME_AVG  AS PO_CYCLE_TIME_AVG,
		MATERIAL_MASTER.TOTAL_12_CONSUMPTION  AS TOTAL_12_CONSUMPTION,
		AVg_Days_Late  AS AVG_DAYS_LATE,
		LINES_ON_TIME  AS LINES_ON_TIME,
		TOTAL_LINES_RECEIVED  AS TOTAL_LINES_RECEIVED,
		OTD  AS OTD,
		receipt_date  AS LAST_RECEIVED_DATE,
		purchase_order
	FROM MATERIAL_MASTER AS MATERIAL_MASTER
	LEFT JOIN INFORECORDS AS INFORECORDS ON INFORECORDS.material_number = MATERIAL_MASTER.material_number AND INFORECORDS.vendor_s_account_number = MATERIAL_MASTER.VENDORS_ACCOUNT_NUMBER
	LEFT JOIN totals_vendor_perf AS totals_vendor_perf ON totals_vendor_perf.MATERIAL = MATERIAL_MASTER.MATERIAL_NUMBER
	LEFT JOIN LAST_PO AS LAST_PO ON LAST_PO.MATERIAL = MATERIAL_MASTER.MATERIAL_NUMBER
	),
source_data
AS (
	SELECT DISTINCT *
	FROM final
	WHERE procurement_type = 'F' AND plant IN ('0010') AND CROSS_PLANT_MATERIAL_STATUS IN ('YA', 'YB', 'YC', 'YD', 'YE', 'YF') AND source_list_usage_in_materials_planning = '1' AND standard_price > 0 AND NET_PRICE_IN_PURCHASING_INFO_RECORD > 0
	ORDER BY MATERIAL_NUMBER ASC
	),
transform_data
AS (
	SELECT 	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        PRIMARYKEY,
		PLANT,
		MATERIAL_NUMBER,
		MATERIAL_DESCRIPTION,
		MATERIAL_NUMBER_USED_BY_VENDOR,
		NUMBER_OF_PURCHASING_INFO_RECORD,
		MATERIAL_GROUP,
		MATERIAL_GROUP_DESCRIPTION,
		PURCHASE_ORDER_UNIT_OF_MEASURE,
		ABC_INDICATOR,
		PURCHASING_GROUP,
		BUYER_NAME,
		BASE_UNIT_OF_MEASURE,
		NET_PRICE_IN_PURCHASING_INFO_RECORD,
		MINIMUM_LOT_SIZE,
		STANDARD_PRICE,
		PRICE_UNIT,
		NET_STANDARD_PRICE,
		MRP_TYPE,
		INFO_REC_LEAD_TIME,
		PLANNING_LEAD_TIME,
		GR_TIME,
		PROCUREMENT_TYPE,
		REORDER_POINT,
		SAFETY_STOCK,
		PROFIT_CENTER,
		PROFIT_CENTER_DESCRIPTION,
		CROSS_PLANT_MATERIAL_STATUS,
		PRICE_VALID_UNTIL,
		VENDORS_ACCOUNT_NUMBER,
		BLOCKED_SOURCE_OF_SUPPLY,
		SUPPLIER_NAME,
		INDICATOR_FIXED_VENDOR,
		SOURCE_LIST_USAGE_IN_MATERIALS_PLANNING,
		COUNTRY_OF_ORIGIN_OF_THE_MATERIAL,
		TOTAL_OPEN_PO_QTY,
		TOTAL_STOCK_OH_QTY,
		TOTAL_DEMAND_QTY,
		TOTAL_EXCESS_QTY,
		DEAD_INV_5Y,
		DEAD_INV_1Y,
		PO_CYCLE_TIME_AVG,
		TOTAL_12_CONSUMPTION,
		AVG_DAYS_LATE,
		LINES_ON_TIME,
		TOTAL_LINES_RECEIVED,
		OTD,
		LAST_RECEIVED_DATE,
		PURCHASE_ORDER
    FROM source_data
	),

type_data as (
       SELECT  _AUDIT_LOG_ID,
        _ROW_HASH,
        PRIMARYKEY,
		PLANT,
		MATERIAL_NUMBER,
		MATERIAL_DESCRIPTION,
		MATERIAL_NUMBER_USED_BY_VENDOR,
		NUMBER_OF_PURCHASING_INFO_RECORD,
		MATERIAL_GROUP,
		MATERIAL_GROUP_DESCRIPTION,
		PURCHASE_ORDER_UNIT_OF_MEASURE,
		ABC_INDICATOR,
		PURCHASING_GROUP,
		BUYER_NAME,
		BASE_UNIT_OF_MEASURE,
		CAST(net_price_in_purchasing_info_record AS NUMBER(32, 2)) AS net_price_in_purchasing_info_record,
		CAST(minimum_lot_size AS number(32, 2)) AS minimum_lot_size,
		CAST(standard_price AS NUMBER(32, 2)) AS standard_price,
		CAST(price_unit AS NUMBER(32, 2)) AS price_unit,
		CAST(NET_STANDARD_PRICE AS NUMBER(32, 2)) AS NET_STANDARD_PRICE,
		mrp_type,
		CAST(Info_rec_lead_time AS NUMBER(32, 0)) AS Info_rec_lead_time,
		CAST(Planning_lead_Time AS NUMBER(32, 0)) AS Planning_lead_Time,
		CAST(GR_Time AS NUMBER(32, 0)) AS GR_Time,
		procurement_type,
		CAST(reorder_point AS NUMBER(32, 2)) AS reorder_point,
		CAST(safety_stock AS NUMBER(32, 2)) AS safety_stock,
		profit_center,
		profit_center_description,
		cross_plant_material_status,
		price_valid_until,
		vendors_account_number,
		blocked_source_of_supply,
		supplier_name,
		indicator_fixed_vendor,
		source_list_usage_in_materials_planning,
		country_of_origin_of_the_material,
		CAST(TOTAL_OPEN_PO_QTY AS NUMBER(32, 2)) AS TOTAL_OPEN_PO_QTY,
		CAST(TOTAL_STOCK_OH_QTY AS NUMBER(32, 2)) AS TOTAL_STOCK_OH_QTY,
		CAST(TOTAL_DEMAND_QTY AS NUMBER(32, 2)) AS TOTAL_DEMAND_QTY,
		CAST(TOTAL_EXCESS_QTY AS NUMBER(32, 2)) AS TOTAL_EXCESS_QTY,
		CAST(DEAD_INV_5Y AS NUMBER(32, 2)) AS DEAD_INV_5Y,
		CAST(DEAD_INV_1Y AS NUMBER(32, 0)) AS DEAD_INV_1Y,
		CAST(PO_CYCLE_TIME_AVG AS NUMBER(32, 2)) AS PO_CYCLE_TIME_AVG,
		CAST(TOTAL_12_CONSUMPTION AS NUMBER(32, 2)) AS TOTAL_12_CONSUMPTION,
		CAST(AVg_Days_Late AS NUMBER(32, 2)) AS AVG_DAYS_LATE,
		CAST(LINES_ON_TIME AS NUMBER(32, 0)) AS LINES_ON_TIME,
		CAST(TOTAL_LINES_RECEIVED AS NUMBER(32, 0)) AS TOTAL_LINES_RECEIVED,
		CAST(OTD AS NUMBER(32, 2)) AS OTD,
		CAST(LAST_RECEIVED_DATE AS DATE) AS LAST_RECEIVED_DATE,
		purchase_order
    FROM transform_data
)

SELECT *
FROM type_data