{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias = 'PURCHASING_SAFETY_STOCK_DEMAND',
        transient = false
) }}

WITH source_data
AS (
	SELECT DISTINCT MARC.material_number AS MATERIAL_NUNBER,
		MAKT.MATERIAL_DESCRIPTION AS MATERIAL_DESCRIPTION,
		MARC.profit_center AS PROFIT_CENTER,
		MARC.safety_stock * - 1 AS SAFETY_STOCK_DEMAND,
		MARC.procurement_type AS PROCUREMENT_TYPE,
		MBEW.standard_price AS STANDARD_PRICE,
		MBEW.price_unit AS PRICE_UNIT,
		MBEW.standard_price / MBEW.price_unit AS NET_PRICE,
		SAFETY_STOCK_DEMAND * NET_PRICE AS SAFETY_STOCK_DEMAND_AMOUNT,
		CURRENT_DATE () AS REQUIREMENT_DATE
	FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PLANT_DATA_FOR_MATERIAL') }} AS MARC
	JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_VALUATION') }} AS MBEW ON MARC.material_number = MBEW.material_number AND MARC.plant = MBEW.valuation_area
	LEFT JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_DESCRIPTIONS') }} AS MAKT ON MAKT.material_number = MARC.material_number
	WHERE SAFETY_STOCK > 0 AND procurement_type = 'F' AND Plant = '0010' AND valuation_area = '0010'
	),
transform_data
AS (
	SELECT
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
	 	MATERIAL_NUNBER,
		MATERIAL_DESCRIPTION,
		PROFIT_CENTER,
		SAFETY_STOCK_DEMAND,
		PROCUREMENT_TYPE,
		STANDARD_PRICE,
		PRICE_UNIT,
		NET_PRICE,
		SAFETY_STOCK_DEMAND_AMOUNT,
		REQUIREMENT_DATE
	FROM source_data
	)
SELECT *
FROM transform_data