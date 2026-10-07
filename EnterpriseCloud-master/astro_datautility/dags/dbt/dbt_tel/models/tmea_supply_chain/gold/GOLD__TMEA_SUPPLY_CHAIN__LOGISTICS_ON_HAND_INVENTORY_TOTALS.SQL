{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias = 'LOGISTICS_ON_HAND_INVENTORY_TOTALS',
        transient = false
) }}

WITH whrstk
AS (
	SELECT DISTINCT mv.material_number,
		md.material_description,
		pdm.profit_center,
		pdm.procurement_type,
		pc.general_name,
		mv.total_valuated_stock,
		mv.standard_price,
		mv.price_unit,
		mv.standard_price * mv.price_unit AS NET_price,
		mv.value_of_total_valuated_stock,
		MV.valuation_area
	FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_VALUATION') }} AS mv
	INNER JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PLANT_DATA_FOR_MATERIAL') }} AS pdm ON pdm.material_number = MV.material_number
		AND pdm.plant = mv.valuation_area
	LEFT JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_DESCRIPTIONS') }} AS md ON md.material_number = mv.material_number
	LEFT JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PROFIT_CENTER_DESCRIPTION') }} AS pc ON pc.profit_center = pdm.profit_center
	WHERE mv.valuation_area IN (
			'0010',
			'0020'
			)
	),
Special_stk
AS (
	SELECT cod.material_number,
		cod.valuated_unrestricted_use_stock AS TOTAL_SPECIAL_STOCK_QTY,
		ads.amount_for_updating_in_general_ledger AS TOTAL_SPECIAL_STOCK_VALUE,
		cod.special_stock_indicator,
		cod.VALUATION_OF_SPECIAL_STOCK
	FROM 
    {{ ref('SILVER__TMEA_SUPPLY_CHAIN__TOTAL_CUSTOMER_ORDERS_ON_HAND') }} AS cod
	INNER JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__ACCOUNTING_DOCUMENT_SEGMENT') }} ads ON cod.sales_and_distribution_document_number = ads.sales_document
		AND cod.ITEM_NUMBER_OF_THE_SD_DOCUMENT = ads.SALES_DOCUMENT_ITEM
		AND cod.material_number = ADS.material_number
		AND cod.special_stock_indicator = 'E'
		AND cod.VALUATION_OF_SPECIAL_STOCK = 'M'
		AND ads.identification_of_the_line_item = 'M'
		AND VALUATED_UNRESTRICTED_USE_STOCK > 0
	),
gl
AS (
	SELECT material_number,
		plant,
		general_ledger_account AS gl_account
	FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__ACCOUNTING_DOCUMENT_SEGMENT') }} AS BSEG
	),
OUTPUT
AS (
	SELECT DISTINCT whrstk.material_number,
		whrstk.material_description,
		whrstk.profit_center,
		whrstk.general_name,
		TOTAL_SPECIAL_STOcK_qty,
		whrstk.total_valuated_stock,
		Total_special_stock_value,
		whrstk.value_of_total_valuated_stock,
		whrstk.net_price,
		gl_account,
		whrstk.valuation_area,
		zeroifnull(Total_special_stock_value) + value_of_total_valuated_stock AS total_stock_value,
		CASE 
			WHEN whrstk.profit_center LIKE '00005%'
				THEN 'GCIB Inv'
			WHEN whrstk.profit_center LIKE '00006%'
				THEN 'FSBU Inv'
			ELSE 'CCS Inv'
			END AS Inventory_type
	FROM whrstk AS whrstk
	LEFT JOIN Special_stk AS Special_stk ON Special_stk.material_number = whrstk.material_number
	LEFT JOIN gl AS gl ON gl.material_number = whrstk.material_number
	),

source_data
AS (
SELECT DISTINCT MATERIAL_NUMBER,
        MATERIAL_DESCRIPTION,
        PROFIT_CENTER,
        GENERAL_NAME,
        TOTAL_SPECIAL_STOCK_QTY,
        TOTAL_VALUATED_STOCK,
        TOTAL_SPECIAL_STOCK_VALUE,
        VALUE_OF_TOTAL_VALUATED_STOCK,
        NET_PRICE,
        GL_ACCOUNT,
        VALUATION_AREA,
        TOTAL_STOCK_VALUE,
        INVENTORY_TYPE
FROM
OUTPUT
WHERE gl_account IN (
		'0000132000',
		'0000134000',
		'0000135000'
		)
ORDER BY total_stock_value DESC
),

 transform_data as (
     select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
        MATERIAL_NUMBER,
        MATERIAL_DESCRIPTION,
        PROFIT_CENTER,
        GENERAL_NAME,
        TOTAL_SPECIAL_STOCK_QTY,
        TOTAL_VALUATED_STOCK,
        TOTAL_SPECIAL_STOCK_VALUE,
        VALUE_OF_TOTAL_VALUATED_STOCK,
        NET_PRICE,
        GL_ACCOUNT,
        VALUATION_AREA,
        TOTAL_STOCK_VALUE,
        INVENTORY_TYPE
     from source_data
 ),

 type_data as (
     select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(MATERIAL_NUMBER AS VARCHAR(16777216)) AS MATERIAL_NUMBER,
        CAST(MATERIAL_DESCRIPTION AS VARCHAR(16777216)) AS MATERIAL_DESCRIPTION,
        CAST(PROFIT_CENTER AS VARCHAR(16777216)) AS PROFIT_CENTER,
        CAST(GENERAL_NAME AS VARCHAR(16777216)) AS GENERAL_NAME,
        CAST(TOTAL_SPECIAL_STOCK_QTY AS NUMBER(38,10)) AS TOTAL_SPECIAL_STOCK_QTY,
        CAST(TOTAL_VALUATED_STOCK AS NUMBER(38,10)) AS TOTAL_VALUATED_STOCK,
        CAST(TOTAL_SPECIAL_STOCK_VALUE AS NUMBER(38,10)) AS TOTAL_SPECIAL_STOCK_VALUE,
        CAST(VALUE_OF_TOTAL_VALUATED_STOCK AS NUMBER(38,10)) AS VALUE_OF_TOTAL_VALUATED_STOCK,
        CAST(NET_PRICE AS NUMBER(38,10)) AS NET_PRICE,
        CAST(GL_ACCOUNT AS VARCHAR(16777216)) AS GL_ACCOUNT,
        CAST(VALUATION_AREA AS VARCHAR(16777216)) AS VALUATION_AREA,
        CAST(TOTAL_STOCK_VALUE AS NUMBER(38,10)) AS TOTAL_STOCK_VALUE,
        CAST(INVENTORY_TYPE AS VARCHAR(16777216)) AS INVENTORY_TYPE
     from transform_data
 )

select * from type_data