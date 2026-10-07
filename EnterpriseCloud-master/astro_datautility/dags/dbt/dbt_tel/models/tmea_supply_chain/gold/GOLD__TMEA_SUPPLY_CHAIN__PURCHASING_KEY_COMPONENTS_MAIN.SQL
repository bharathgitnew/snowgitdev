{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='PURCHASING_KEY_COMPONENTS_MAIN',
    	transient=false
) }}

WITH ref_cte_GENERAL_MATERIAL_DATA as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__GENERAL_MATERIAL_DATA') }}
),

ref_cte_MATERIAL_DESCRIPTIONS as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_DESCRIPTIONS') }}
),

ref_cte_MATERIAL_GROUP_DESCRIPTIONS as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_GROUP_DESCRIPTIONS') }}
),

ref_cte_MATERIAL_VALUATION as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_VALUATION') }}
),

ref_cte_PLANT_DATA_FOR_MATERIAL as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PLANT_DATA_FOR_MATERIAL') }}
),

ref_cte_PROFIT_CENTER_DESCRIPTION as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PROFIT_CENTER_DESCRIPTION') }}
),

ref_cte_PURCHASING_GROUPS as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PURCHASING_GROUPS') }}
),

ref_cte_PURCHASING_INFO_RECORD_GENERAL_DATA as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PURCHASING_INFO_RECORD_GENERAL_DATA') }}
),

ref_cte_PURCHASING_INFO_RECORD_PURCHASING_ORGANIZATION_DATA as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PURCHASING_INFO_RECORD_PURCHASING_ORGANIZATION_DATA') }}
),

ref_cte_PURCHASING_SOURCE_LIST as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PURCHASING_SOURCE_LIST') }}
),

ref_cte_VENDOR_MASTER as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__VENDOR_MASTER') }}
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
			ven.name_1 AS Supplier_Name,
			EORD.indicator_fixed_vendor,
			EORD.source_list_usage_in_materials_planning,
			MARC.country_of_origin_of_the_material,
			CONCAT (
				MARA.material_number,
				EORD.vendors_account_number
				) AS PrimaryKey,
			CASE WHEN EORD.indicator_fixed_vendor = 'X' THEN 'Primary' ELSE 'Other' END AS Supplier_Type
		FROM ref_cte_GENERAL_MATERIAL_DATA AS MARA
		LEFT JOIN ref_cte_PLANT_DATA_FOR_MATERIAL AS MARC ON MARC.material_number = MARA.material_number
		LEFT JOIN ref_cte_MATERIAL_DESCRIPTIONS AS MAKT ON MAKT.material_number = MARA.material_number
		LEFT JOIN ref_cte_PURCHASING_SOURCE_LIST AS EORD ON EORD.material_number = MARA.material_number AND EORD.plant = MARC.plant
		LEFT JOIN ref_cte_MATERIAL_VALUATION AS MBEW ON MBEW.material_number = MARC.material_number AND MBEW.valuation_area = MARC.plant
		LEFT JOIN ref_cte_MATERIAL_GROUP_DESCRIPTIONS AS T023T ON T023T.material_group = MARA.material_group
		LEFT JOIN ref_cte_PROFIT_CENTER_DESCRIPTION AS CEPC ON CEPC.profit_center = MARC.profit_center
		LEFT JOIN ref_cte_VENDOR_MASTER AS ven ON EORD.vendors_account_number = ven.account_number_of_vendor_or_creditor
		LEFT JOIN ref_cte_PURCHASING_GROUPS AS T024 ON T024.purchasing_group = MARC.purchasing_group
		WHERE T024.SPOOL_OUTPUT_DEVICE = 'EMAI' AND MBEW.valuation_area IN ('0010') AND EORD.is_deleted = 'No' AND EORD.VENDORS_ACCOUNT_NUMBER <> ' '
		),
	INFORECORDS AS (
		SELECT DISTINCT irgd.material_number,
			prpod.plant,
			irgd.material_number_used_by_vendor,
			IRGD.number_of_purchasing_info_record,
			irgd.vendor_s_account_number,
			irgd.purchase_order_unit_of_measure,
			irgd.base_unit_of_measure,
			prpod.net_price_in_purchasing_info_record,
			prpod.price_valid_until,
			prpod.planned_delivery_time_in_days AS Info_rec_lead_time
		FROM ref_cte_PURCHASING_INFO_RECORD_GENERAL_DATA AS IRGD
		JOIN ref_cte_PURCHASING_INFO_RECORD_PURCHASING_ORGANIZATION_DATA AS prpod ON irgd.number_of_purchasing_info_record = prpod.number_of_purchasing_info_record
		WHERE irgd.vendor_material_group IS NOT NULL AND prpod.NUMBER_OF_PURCHASING_INFO_RECORD IS NOT NULL AND PRPOD.PURCHASING_INFO_RECORD_CATEGORY NOT IN ('2', '3') AND prpod.purchasing_organization = '0040' AND prpod.plant = '0010'
		),
	final AS (
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
			INFORECORDS.net_price_in_purchasing_info_record,
			MATERIAL_MASTER.minimum_lot_size,
			MATERIAL_MASTER.standard_price,
			MATERIAL_MASTER.price_unit,
			MATERIAL_MASTER.NET_STANDARD_PRICE,
			MATERIAL_MASTER.mrp_type,
			INFORECORDS.Info_rec_lead_time,
			MATERIAL_MASTER.Planning_lead_Time,
			MATERIAL_MASTER.goods_receipt_processing_time_in_days AS GR_TIME,
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
			MATERIAL_MASTER.country_of_origin_of_the_material
		FROM MATERIAL_MASTER AS MATERIAL_MASTER
		LEFT JOIN INFORECORDS AS INFORECORDS ON INFORECORDS.material_number = MATERIAL_MASTER.material_number AND INFORECORDS.vendor_s_account_number = MATERIAL_MASTER.VENDORS_ACCOUNT_NUMBER
		),
	source_data AS (
		SELECT DISTINCT *
		FROM final
		WHERE procurement_type = 'F' 
		AND plant IN ('0010') 
		AND CROSS_PLANT_MATERIAL_STATUS IN ('YA', 'YB', 'YC', 'YD', 'YE', 'YF') 
		AND source_list_usage_in_materials_planning = '1' 
		AND standard_price > 0 
		AND NET_PRICE_IN_PURCHASING_INFO_RECORD > 0 
		--AND SUPPLIER_NAME LIKE 'FERRO%' OR SUPPLIER_NAME LIKE 'Ferro%' 
		--AND safety_stock > 0
		),
	transform_data AS (
		SELECT 
			'{{ invocation_id }}' AS _AUDIT_LOG_ID,
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
			COUNTRY_OF_ORIGIN_OF_THE_MATERIAL
			
		FROM source_data
		),
type_data AS (
        SELECT  
			_AUDIT_LOG_ID,
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
			CAST(NET_PRICE_IN_PURCHASING_INFO_RECORD AS NUMBER(32, 2)) AS net_price_in_purchasing_info_record,
			CAST(MINIMUM_LOT_SIZE AS number(32, 2)) AS minimum_lot_size,
			CAST(standard_price AS NUMBER(32, 2)) AS standard_price,
			CAST(price_unit AS NUMBER(32, 2)) AS price_unit,
			CAST(NET_STANDARD_PRICE AS NUMBER(32, 2)) AS NET_STANDARD_PRICE,
			mrp_type,
			CAST(Info_rec_lead_time AS NUMBER(32, 0)) AS Info_rec_lead_time,
			CAST(Planning_lead_Time AS NUMBER(32, 0)) AS Planning_lead_Time,
			CAST(GR_TIME AS NUMBER(32, 0)) AS GR_Time,
			procurement_type,
			CAST(reorder_point AS NUMBER(32, 2)) AS reorder_point,
			CAST(safety_stock AS NUMBER(32, 2)) AS safety_stock,
			PROFIT_CENTER,
			PROFIT_CENTER_DESCRIPTION,
			CROSS_PLANT_MATERIAL_STATUS,
			PRICE_VALID_UNTIL,
			VENDORS_ACCOUNT_NUMBER,
			BLOCKED_SOURCE_OF_SUPPLY,
			SUPPLIER_NAME,
			INDICATOR_FIXED_VENDOR,
			SOURCE_LIST_USAGE_IN_MATERIALS_PLANNING,
			COUNTRY_OF_ORIGIN_OF_THE_MATERIAL

FROM transform_data
		)

SELECT *
FROM type_data