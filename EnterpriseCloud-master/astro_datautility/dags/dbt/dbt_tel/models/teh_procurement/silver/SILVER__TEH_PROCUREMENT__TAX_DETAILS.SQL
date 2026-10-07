{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TAX_DETAILS'
) }}

with source_data AS (
	SELECT
		"CLIENT" AS CLIENT, 
 	 	"PARTNER" AS BUSINESS_PARTNER, 
 	 	"TAXTYPE" AS TAX_NUMBER_CATEGORY, 
 	 	"TAXNUM" AS TAX_NUM, 
 	 	"TAXNUMXL" AS TAX_NUM_XL
	from {{ ref('BRONZE__TEH_PROCUREMENT__SAPAPI_ZCDV_T_CMTU212_DFKKBPTAXNUM') }}

	),
	
transform_data AS (
	SELECT 
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
		CLIENT,
        BUSINESS_PARTNER,
        TAX_NUMBER_CATEGORY,
        TAX_NUM,
        TAX_NUM_XL
	from source_data
	),
	
	type_data AS (
	SELECT
        _AUDIT_LOG_ID AS _AUDIT_LOG_ID,
        _ROW_HASH AS _ROW_HASH,
		CLIENT AS CLIENT,
        BUSINESS_PARTNER AS BUSINESS_PARTNER,
        TAX_NUMBER_CATEGORY AS TAX_NUMBER_CATEGORY,
        TAX_NUM AS TAX_NUM,
        TAX_NUM_XL AS TAX_NUM_XL
	from transform_data
	)

	select * from type_data