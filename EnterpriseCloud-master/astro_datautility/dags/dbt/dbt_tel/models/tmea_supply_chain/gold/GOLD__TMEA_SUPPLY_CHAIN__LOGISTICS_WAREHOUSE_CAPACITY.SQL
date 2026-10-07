{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='LOGISTICS_WAREHOUSE_CAPACITY',
    	transient=false
) }}

WITH source_data as (

SELECT sb.storage_type,
	sd.name_of_storage_type,
	count_if(sb.indicator_whether_storage_bin_is_empty <> 'X') AS Total_Ocupied,
	count_if(sb.indicator_whether_storage_bin_is_empty IN ('X')) AS Total_EMPTY,
	CASE 
		WHEN total_ocupied = 0
			THEN 0
		ELSE total_ocupied / (total_empty + total_ocupied)
		END AS usage
FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__STORAGE_BINS') }}  AS sb
LEFT JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__STORAGE_TYPE_DESCRIPTIONS') }} AS sd ON sd.warehouse_number_warehouse_complex = sb.warehouse_number_warehouse_complex
	AND sd.storage_type = sb.storage_type
WHERE sb.warehouse_number_warehouse_complex IN ('010')
	AND sb.blocking_indicator_current_inventory <> 'X'
	AND sb.blocking_indicator_current_stock_placement <> 'X'
	AND sb.blocking_indicator_current_stock_removal <> 'X'
	AND sb.blocking_indicator_for_putaways <> 'X'
	AND sb.blocking_indicator_for_stock_removals <> 'X'
GROUP BY sb.storage_type,
	sd.name_of_storage_type
    
    ),

 transform_data as (
	select 
 		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		STORAGE_TYPE,
		NAME_OF_STORAGE_TYPE,
		TOTAL_OCUPIED,
		TOTAL_EMPTY,
		USAGE
 from source_data
 ),

 type_data as (
 select
 	CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
	cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
	CAST(STORAGE_TYPE AS VARCHAR(16777216)) AS STORAGE_TYPE,
	CAST(NAME_OF_STORAGE_TYPE AS VARCHAR(16777216)) AS NAME_OF_STORAGE_TYPE,
	CAST(TOTAL_OCUPIED AS NUMBER(38,10)) AS TOTAL_OCUPIED,
	CAST(TOTAL_EMPTY AS NUMBER(38,10)) AS TOTAL_EMPTY,
	CAST(USAGE AS NUMBER(38,10)) AS USAGE
 from transform_data 
 )
select * from type_data