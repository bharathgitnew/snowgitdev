{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias = 'PURCHASING_RTVS_STOCK',
        transient = false
) }}

WITH source_data
AS (
	SELECT MARD.MATERIAL_NUMBER,
		MAKT.material_description,
		t024.purchasing_group,
		t024.description_of_purchasing_group,
		EORD.VENDORS_ACCOUNT_NUMBER,
		LFA1.NAME_1,
		MARD.PLANT,
		MARD.STORAGE_LOCATION,
		CAST((MBEW.STANDARD_PRICE / MBEW.PRICE_UNIT) AS NUMBER(38, 2)) AS STANDARD_PRICE,
		CAST(MARD.VALUATED_UNRESTRICTED_USE_STOCK AS NUMBER(38, 2)) AS STOCK_QUANTITY,
		CAST(STANDARD_PRICE * STOCK_QUANTITY AS NUMBER(38, 2)) AS EXTENDED_COST,
		CAST(MARD._CAPTUREDATETIME AS DATE) AS posting_date,
		CAST(CURRENT_DATE AS DATE) AS ACTUAL_DATE,
		datediff(day, posting_date, ACTUAL_DATE) AS AGING
	FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__STORAGE_LOCATION_DATA_FOR_MATERIAL') }} AS MARD
	JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_DESCRIPTIONS') }} AS MAKT ON MAKT.material_number = MARD.material_number
	JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PLANT_DATA_FOR_MATERIAL') }} AS MARC ON MARC.material_number = MARD.material_number AND MARC.plant = MARD.plant
	JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PURCHASING_GROUPS') }} AS T024 ON T024.purchasing_group = MARC.purchasing_group
	JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PURCHASING_SOURCE_LIST') }} AS EORD ON EORD.material_number = MARD.material_number AND EORD.plant = MARD.plant
	JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__VENDOR_MASTER') }} AS LFA1 ON EORD.vendors_account_number = LFA1.account_number_of_vendor_or_creditor
	JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_VALUATION') }} AS MBEW ON MBEW.material_number = MARD.material_number AND MBEW.valuation_area = MARD.plant
	WHERE T024.SPOOL_OUTPUT_DEVICE = 'EMAI' AND storage_location = 'RTVS' AND mard.PLANT = '0010' AND VALUATION_AREA IN ('0010') AND VALUATED_UNRESTRICTED_USE_STOCK <> 0 AND eord.indicator_fixed_vendor = 'X'
	),
transform_data AS (
		SELECT 
            '{{ invocation_id }}' AS _AUDIT_LOG_ID,
	        SHA2('hash_me') as _ROW_HASH,
			MATERIAL_NUMBER,
			MATERIAL_DESCRIPTION,
			PURCHASING_GROUP,
			DESCRIPTION_OF_PURCHASING_GROUP,
			VENDORS_ACCOUNT_NUMBER,
			NAME_1,
			PLANT,
			STORAGE_LOCATION,
			STANDARD_PRICE,
			STOCK_QUANTITY,
			EXTENDED_COST,
			POSTING_DATE,
			ACTUAL_DATE,
			AGING
		FROM source_data
		) select *
FROM transform_data