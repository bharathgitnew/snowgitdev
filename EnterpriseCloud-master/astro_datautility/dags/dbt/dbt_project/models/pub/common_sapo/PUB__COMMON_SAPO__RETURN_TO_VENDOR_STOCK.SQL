/**********************************
File built from dbt_code_generator.ipynb
model file generated on: 2022-08-12 12:49:10.987611
***********************************/

{{ config(
        materialized='view',
         alias='RETURN_TO_VENDOR_STOCK',
         transient=false
) }}

with source_data as
(   
    SELECT
        MATERIAL_NO, 
		PLANT, 
		MRP_CONTROLLER, 
		DOCUMENT_NO, 
		MOVEMENT_TYPE, 
		STORAGE_LOC, 
		QTY, 
		UNIT, 
		BUN, 
		TOTAL_STOCK, 
		TOTAL_VALUE, 
		POSTING_DATE, 
		TIME_OF_ENTRY, 
		CURRENCY
    FROM {{ source('COMMON__SAPO', 'RETURN_TO_VENDOR_STOCK') }}
), 

transform_data as
(
 SELECT * FROM source_data
)

SELECT * FROM transform_data