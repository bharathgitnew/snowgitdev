/************
Model file generated from legacy93DbtTemplateUtility.ipynb 
*************/


{{ config(
    	materialized='incremental',
    	incremental_strategy='insert_overwrite',
    	alias='BAANV_ALL_COMMODITIES',
    	transient=false
) }} 

with source_data as (
	SELECT
		JSONFIELD:"COMPANY_NO"::STRING AS "COMPANY_NO", 
 	 	JSONFIELD:"COMMODITY_CODE"::STRING AS "COMMODITY_CODE", 
 	 	JSONFIELD:"DESCRIPTION"::STRING AS "DESCRIPTION"
	FROM {{ source('LEGACY93','BAANV_ALL_COMMODITIES') }}
    WHERE _FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('LEGACY93','BAANV_ALL_COMMODITIES') }})
),

transform_data as (
	SELECT 
		"COMPANY_NO", 
 	 	"COMMODITY_CODE", 
 	 	"DESCRIPTION",
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH
	FROM source_data
),

type_data as (
	SELECT
		AUDIT_LOG_ID,
		_ROW_HASH,
		"COMPANY_NO", 
 	 	"COMMODITY_CODE", 
 	 	"DESCRIPTION"
	FROM transform_data
)

SELECT * FROM type_data