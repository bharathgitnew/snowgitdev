/************
Model file generated from legacy93DbtTemplateUtility.ipynb 
*************/


{{ config(
    	materialized='incremental',
    	incremental_strategy='insert_overwrite',
    	alias='BAANV_ALL_ITEM_GROUPS',
    	transient=false
) }} 

with source_data as (
	SELECT
		JSONFIELD:"COMPANY_NO"::STRING AS "COMPANY_NO", 
 	 	JSONFIELD:"ITEM_GROUP"::STRING AS "ITEM_GROUP", 
 	 	JSONFIELD:"DESCRIPTION"::STRING AS "DESCRIPTION"
	FROM {{ source('LEGACY93','BAANV_ALL_ITEM_GROUPS') }}
    WHERE _FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('LEGACY93','BAANV_ALL_ITEM_GROUPS') }})
),

transform_data as (
	SELECT 
		"COMPANY_NO", 
 	 	"ITEM_GROUP", 
 	 	"DESCRIPTION",
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH
	FROM source_data
),

type_data as (
	SELECT
		AUDIT_LOG_ID,
		_ROW_HASH,
		CAST("COMPANY_NO" AS NUMBER(38,0)) AS "COMPANY_NO", 
 	 	"ITEM_GROUP", 
 	 	"DESCRIPTION"	
	FROM transform_data
)

SELECT * FROM type_data