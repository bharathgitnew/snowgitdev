{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='PURCHASING_PO_LINES_INVOICED',
    	transient=false
) }}

WITH PO_Invoices
AS (
	SELECT Inv.material_number,
		Inv.gr_ir_acc_clearing_value_local_curr AS Total_invoiced,
		Inv.PURCHASING_DOCUMENT_NUMBER,
		Inv.purchase_order_history_category,
		Inv.item_number_of_purchasing_document,
		Inv.ITEM_OF_A_REFERENCE_DOCUMENT,
		Inv.NUMBER_OF_MATERIAL_DOCUMENT,
		inv.posting_date_in_the_document,
		inv.TAX_ON_SALES_PURCHASES_CODE,
		ven_per.vendor AS supplier,
		pdm.profit_center
	FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__HISTORY_PER_PURCHASING_DOCUMENT') }} AS Inv
	INNER JOIN {{ ref('GOLD__TMEA_SUPPLY_CHAIN__PURCHASING_VENDOR_PERFORMANCE') }} AS Ven_Per ON Inv.purchasing_document_number = Ven_Per.PURCHASE_ORDER
		AND Inv.ITEM_NUMBER_OF_PURCHASING_DOCUMENT = Ven_per.PO_LINE_ITEM
	INNER JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PLANT_DATA_FOR_MATERIAL') }} AS pdm ON pdm.material_number = inv.material_number
		AND pdm.plant = inv.plant
	WHERE pdm.plant = '0010'
	),
Systems
AS (
	SELECT pc.profit_center,
		pd.general_name
	FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PROFIT_CENTER_MASTER_DATA') }} AS pc
	LEFT JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PROFIT_CENTER_DESCRIPTION') }} AS pd ON pc.profit_center = pd.profit_center
	),
Final_output
AS (
	SELECT DISTINCT CONCAT (
			PO_Invoices.material_number,
			PO_Invoices.supplier
			) AS PRIMARYKEY,
		PO_Invoices.material_number,
		PO_Invoices.Total_invoiced,
		PO_Invoices.PURCHASING_DOCUMENT_NUMBER,
		PO_Invoices.purchase_order_history_category,
		PO_Invoices.item_number_of_purchasing_document,
		PO_Invoices.ITEM_OF_A_REFERENCE_DOCUMENT,
		PO_Invoices.NUMBER_OF_MATERIAL_DOCUMENT,
		PO_Invoices.posting_date_in_the_document,
		PO_Invoices.TAX_ON_SALES_PURCHASES_CODE,
		PO_Invoices.supplier,
		PO_Invoices.profit_center,
		Systems.general_name AS Profit_center_description,
		CASE 
			WHEN PO_Invoices.profit_center = '0000510210'
				THEN 'ACREVIA'
			WHEN PO_Invoices.profit_center = '0000410240'
				THEN 'ANTARES'
			WHEN PO_Invoices.profit_center = '0000410220'
				THEN 'MERCURY'
			WHEN PO_Invoices.profit_center = '0000510205'
				THEN 'UT PLUS'
			WHEN PO_Invoices.profit_center = '0000410281'
				THEN 'SPARES'
			WHEN PO_Invoices.profit_center = '0000410245'
				THEN 'ORION'
			WHEN PO_Invoices.profit_center = '0000410225'
				THEN 'ZETA'
			WHEN PO_Invoices.profit_center = '0000510225'
				THEN 'POSEIDON'
			ELSE 'LEGACY'
			END AS System
	FROM PO_Invoices AS PO_Invoices
	INNER JOIN systems AS systems ON PO_Invoices.profit_center = systems.profit_center
	),
source_data as (
SELECT DISTINCT *
FROM Final_output
WHERE material_number <> ' '
	AND TAX_ON_SALES_PURCHASES_CODE <> ' '
	AND posting_date_in_the_document > '2021-01-01'
ORDER BY posting_date_in_the_document,
	PURCHASING_DOCUMENT_NUMBER DESC
    ),

 transform_data as (
 select 
 		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		PRIMARYKEY,
		MATERIAL_NUMBER,
		TOTAL_INVOICED,
		PURCHASING_DOCUMENT_NUMBER,
		PURCHASE_ORDER_HISTORY_CATEGORY,
		ITEM_NUMBER_OF_PURCHASING_DOCUMENT,
		ITEM_OF_A_REFERENCE_DOCUMENT,
		NUMBER_OF_MATERIAL_DOCUMENT,
		POSTING_DATE_IN_THE_DOCUMENT,
		TAX_ON_SALES_PURCHASES_CODE,
		SUPPLIER,
		PROFIT_CENTER,
		PROFIT_CENTER_DESCRIPTION,
		SYSTEM
 from source_data
 ),

 type_data as (
 select
 	CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
	cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
	CAST(PRIMARYKEY AS VARCHAR(16777216)) AS PRIMARYKEY,
	CAST(MATERIAL_NUMBER AS VARCHAR(16777216)) AS MATERIAL_NUMBER,
	CAST(TOTAL_INVOICED AS VARCHAR(16777216)) AS TOTAL_INVOICED,
	CAST(PURCHASING_DOCUMENT_NUMBER AS VARCHAR(16777216)) AS PURCHASING_DOCUMENT_NUMBER,
	CAST(PURCHASE_ORDER_HISTORY_CATEGORY AS VARCHAR(16777216)) AS PURCHASE_ORDER_HISTORY_CATEGORY,
	CAST(ITEM_NUMBER_OF_PURCHASING_DOCUMENT AS VARCHAR(16777216)) AS ITEM_NUMBER_OF_PURCHASING_DOCUMENT,
	CAST(ITEM_OF_A_REFERENCE_DOCUMENT AS VARCHAR(16777216)) AS ITEM_OF_A_REFERENCE_DOCUMENT,
	CAST(NUMBER_OF_MATERIAL_DOCUMENT AS VARCHAR(16777216)) AS NUMBER_OF_MATERIAL_DOCUMENT,
	CAST(POSTING_DATE_IN_THE_DOCUMENT AS DATE) AS POSTING_DATE_IN_THE_DOCUMENT,
	CAST(TAX_ON_SALES_PURCHASES_CODE AS VARCHAR(16777216)) AS TAX_ON_SALES_PURCHASES_CODE,
	CAST(SUPPLIER AS VARCHAR(16777216)) AS SUPPLIER,
	CAST(PROFIT_CENTER AS VARCHAR(16777216)) AS PROFIT_CENTER,
	CAST(PROFIT_CENTER_DESCRIPTION AS VARCHAR(16777216)) AS PROFIT_CENTER_DESCRIPTION,
	CAST(SYSTEM AS VARCHAR(16777216)) AS SYSTEM
 from transform_data 
 )
select * from type_data