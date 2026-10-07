/**********************************
File built from dbt_code_generator.ipynb
model file generated on: 2022-08-12 12:49:04.573269
***********************************/

{{ config(
        materialized='view',
         alias='MATERIAL_REVIEW_BOARD_FLOOR_QUALITY_CONTROL',
         transient=false
) }}

with source_data as
(   
    SELECT
        MATERIAL, 
		MATERIAL_DESCRIPTION, 
		TOTAL_QTY, 
		BUN, 
		TYPE, 
		STORAGE_BIN, 
		STANDARD_COST, 
		EXTENDED_COST, 
		LAST_PLACEMENT_DATE, 
		BUN2, 
		LAST_PLACEMENT_TIME, 
		PLANT, 
		INSP_LOT_NO, 
		TFR_REQ, 
		GR_DATE, 
		MRP_CONT_DESC, 
		PUR_GRP_DESC, 
		TOTAL_VALUATED_STOCK, 
		TOTAL_VALUE, 
		PLANNED_DELIVERY_TIME, 
		AVAILABLE_STOCK
    FROM {{ source('COMMON__SAPO', 'MATERIAL_REVIEW_BOARD_FLOOR_QUALITY_CONTROL') }}
), 

transform_data as
(
 SELECT * FROM source_data
)

SELECT * FROM transform_data