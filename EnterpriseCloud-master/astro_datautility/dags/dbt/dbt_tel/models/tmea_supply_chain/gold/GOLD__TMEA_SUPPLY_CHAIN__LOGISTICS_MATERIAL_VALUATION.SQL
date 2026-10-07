{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias = 'LOGISTICS_MATERIAL_VALUATION',
        transient = false
) }}



WITH source_data
AS (
	SELECT mv.MATERIAL_NUMBER,
		pdm.procurement_type,
		pdm.profit_center,
		VALUATION_AREA,
		TOTAL_VALUATED_STOCK AS TOTAL_STOCK_ON_HAND,
		VALUE_OF_TOTAL_VALUATED_STOCK AS TOTAL_VALUE_STOCK_ON_HAND,
		STANDARD_PRICE,
		PRICE_UNIT,
		pdm.safety_stock,
		STANDARD_PRICE / PRICE_UNIT AS NET_PRICE,
		pdm.safety_stock * - 1 * NET_PRICE AS safety_stock_value
	FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_VALUATION') }} AS mv
	LEFT JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PLANT_DATA_FOR_MATERIAL') }} AS pdm ON pdm.material_number = MV.material_number AND pdm.plant = mv.valuation_area
	WHERE valuation_area IN ('0010')
	),
transform_data
AS (
	SELECT 
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		MATERIAL_NUMBER,
		PROCUREMENT_TYPE,
		PROFIT_CENTER,
		VALUATION_AREA,
		TOTAL_STOCK_ON_HAND,
		TOTAL_VALUE_STOCK_ON_HAND,
		STANDARD_PRICE,
		PRICE_UNIT,
		SAFETY_STOCK,
		NET_PRICE,
		SAFETY_STOCK_VALUE
	FROM source_data
	)
SELECT *
FROM transform_data